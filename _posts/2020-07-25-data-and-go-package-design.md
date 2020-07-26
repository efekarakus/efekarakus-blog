---
layout: post
title: Data and Go package design
tags: [golang]
---
> There are two important rules governing levels of abstractions. The first concerns resources (I/O devices, data): **each level has resources which it owns exclusively and which other levels are not permitted to access.**    
\- Barbara Liskov [[1]](#1)  
>
>
> Every module in the second decomposition is characterized by its knowledge of a design decision
which it hides from all others. **Its interface or definition was chosen to reveal as little as possible about its inner workings.**  
\- David Parnas [[2]](#2)


This post explores how to make Go packages more flexible by showing how to vend data types from packages.

### Consider multiple named return values over small structs
 
A `struct` is an aggregate data type with zero or more fields. If a method is returning a small struct composed of fields with std library types, changing its signature to use named return values will make it more flexible. 

```go
package github

type Auth struct {
  Username string
  Password string
}

func (c *Client) Auth() (Auth, error)
```
A consumer of the `github` package will find it hard to swap the `Client` object because the `Auth` method returns a struct namespaced under `github.Auth`. Instead consider the following signature with named return values:

```go
package gitlab

func (c *Client) Auth() (username, password string, err error)
```
This signature makes it very easy for another package, say `gitlab`, to also implement the same definition while maintaining readability. Now, as a consumer I can define the following interface and use either a `github.Client` or `gitlab.Client`:
```go
type Auth interface {
  Auth() (string, string, error)
}
```

### Consider larger packages
When multiple types across packages satisfy the same contract, consider grouping them into a single package. Following the example above, instead of having two separate packages, `gitlab` and `github`, we can keep the `Auth` struct and define a new `gitrepo` package:
```go
package gitrepo

func (c *GitHubClient) Auth() (Auth, error)
func (c *GitLabClient) Auth() (Auth, error)
```
A consumer that defines the following interface still has the flexibility of choosing either a `GitHubClient` or `GitLabClient`:
```go
type Auth interface { 
  Auth() (gitrepo.Auth, error) 
}
```
By grouping several types that satisfy the same interface in the `gitrepo` package we increased its flexibility.

### Consider only accepting and returning data types defined in your package
Following the advice from Liskov and Parnas, ensure that your package's public API can evolve by _not_ consuming or exposing dependency data types with the exception of the std library.   

To illustrate, let's take a look at the following method in the `gitrepo` package:

```go
package gitrepo

// github.Auth and github.Repository are not owned by this pkg.
func (c *Client) Repository(auth github.Auth, name string) (github.Repository, error) 
```
The `Repository` method will struggle to evolve if it wants to support additional functionality in a backwards compatible manner.
For example, we cannot augment the `Repository` method to also work with one-time passwords (OTP) since `gitrepo` does not own the `github.Auth` type. It cannot add the optional `OTP` field to the struct. Instead, we'll have to create a new method `RepositoryWithOTP` to be able to handle the feature request. On the other hand, if we define and accept our own `Auth` type then the optional field can be added safely without introducing a breaking change.

```go
package repo

type Auth struct {
  Username string
  Password string

  // Optional, one-time password.
  // Can be specified instead of Password.
  OTP string 
}

func (c *Client) Repository(auth Auth, name string) (github.Repository, error)
```

The `Repository` method still outputs a `github.Repository` type which leaks the internals of the package. 
A reader knows that the package uses and only works with the `github` dependency. Instead, if we define our own
`gitrepo.Repository` type then internally the `Repository` method can choose to either use a `github.Repository` or `gitlab.Repository`.

```go
package repo

type Auth struct {
  Username string
  Password string
  OTP string
}

type Repository struct {
  Owner string
}

func (c *Client) Repository(auth Auth, name string) (Repository, error) {
  // We can fetch either a github.Repository
  // Or a gitlab.Repository.
}
```
### Takeaways


### Further reading

<span id="1">[[1]](#1)</span> Liskov, Barbara H. ["A design methodology for reliable software systems."](https://pdfs.semanticscholar.org/d420/c8b473a23b80241fd7c90757becb59b1136c.pdf) Proceedings of the December 5-7, 1972, fall joint computer conference, part I. 1972. 

<span id="2">[[2]](#2)</span> Parnas, David L. ["On the criteria to be used in decomposing systems into modules."](https://apps.dtic.mil/sti/pdfs/AD0773837.pdf) Pioneers and Their Contributions to Software Engineering. Springer, Berlin, Heidelberg, 1972. 479-498.