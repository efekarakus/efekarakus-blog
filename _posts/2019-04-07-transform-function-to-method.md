---
layout: post
title: Transform function to method
categories: [refactoring, golang]
---

```go
// before
func EnrichReading(r *Reading) { ... }

// after
func (r *Reading) Enrich() { ... }
```

## Scenario [#](#scenario-)
A few days ago, I worked on transforming a [YAML](https://yaml.org/) file that represents a small web application into a [CloudFormation (CFN)](https://aws.amazon.com/cloudformation/aws-cloudformation-templates/) template.

This is roughly the code that I started with in `service/web.go`:
```go
package service

type Web struct {
	Name      string `yaml:"name"`
	ImageURL  string `yaml:"imageUrl"`
	CPU       int    `yaml:"cpu"`
	Memory    int    `yaml:"memory"`
}

func CFNTemplate(w *Web) string {
  return `
AWSTemplateFormatVersion: '2010-09-09'
Parameters:
  ServiceName:
    Type: String
    Default: ` + w.Name + `
  ImageUrl:
    Type: String
    Default: ` + w.ImageURL + `
  ContainerCpu:
    Type: Number
    Default: ` + w.CPU + `
  ContainerMemory:
    Type: Number
    Default: ` + w.Memory 
    // the rest of the template
}
```

What are some problems with this code?
1. It's not _extensible_. I know that later on I'll have to parse other types of services that will be transformed to a CFN template. Since `service.CFNTemplate` only accepts a `*service.Web`, it can't work with other types. The impact here is within the `service` package.
1. It _locks_ any customer of `service.CFNTemplate` to `service.Web`. This is related to the previous point, but this time the impact is upstream. The chain of functions that end up invoking `service.CFNTemplate` will need to be updated once we allow it to accept a more generic type.

## Refactoring [#](#refactoring-) 
To deal with the _extensibility_ problem, we can instead [transform the function to a method]({% post_url 2019-04-07-transform-function-to-method %}):
```go
func (w *Web) CFNTemplate() string { ... }
```
Now, each new `service` type can implement its own `CFNTemplate` method. It won't need to be tied down to the `Web` type.

To deal with the _lock in_ problem, the caller can instead accept an interface. Here is an example:
```go
package main

type CFNTemplater interface {
  CFNTemplate() string
}

func deployStack(client *cloudformation.Cloudformation, srv CFNTemplater) {
  ...
  tpl := srv.CFNTemplate()
  ...
}
```
This is pretty powerful and it reminds me of the general security advice of granting [least privilege](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html#grant-least-privilege). The function went from accepting a particular struct, `*service.Web`, that has a bunch of other methods that `deployStack` doesn't care about to only accepting what it needs: the `CFNTemplate` method.

## Mechanics [#](#mechanics-)
The steps for this refactoring is similar to [Combine Functions into Class](https://refactoring.com/catalog/combineFunctionsIntoClass.html) from Martin Fowler's [refactoring book](https://martinfowler.com/books/refactoring.html).
1. Create a new struct for the data that's common between functions.
2. Transform the function to a method by adding the new struct as a receiver.

## Conclusion [#](#conclusion-)
Here are some rules of thumb when you hesitate between creating a function or a method:
1. If your function is accessing fields in your struct, instead consider transforming to a method.
2. Replace any upstream function that accepted the struct as a parameter with an interface of the method needed for flexibility. 

Categories [refactoring]({% post_url 2019-04-07-refactorings-in-golang %})