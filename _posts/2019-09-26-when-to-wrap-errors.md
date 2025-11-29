---
layout: post
title: When to add context to errors
tagline: "Wrap errors at public function boundaries, not at every internal call. Your error messages will be more concise without losing the information users actually need."
categories: [golang]
---

This post looks into when to add additional information to errors with `fmt.Errorf`, so that
a **human** can make sense of the error. The human can be both a user of your software or you 
as the developer.

## TL;DR [#](#tldr-)

Add additional context to errors returned from public functions or methods. Otherwise, propagate them.

## Problem statement [#](#problem-statement-)

```go
if err != nil {
  return err
}
// or
if err != nil {
  return fmt.Errorf("my description: %w", err)
}
```

You can add more context to your errors in Go by using `fmt.Errorf` or a library like [pkg/errors](https://godoc.org/github.com/pkg/errors). Ideally, users should be able to fix their issue by reading the additional context printed, or there is a bug in the software. How can we wrap our errors such that we provide our users just the right amount of information?

Unfortunately, there is little guidance (that I could find) on when to wrap your errors besides wrapping them as soon as they occur:

> Minimise the number of sentinel error values in your program and convert errors to opaque errors by wrapping them with `errors.Wrap` as soon as they occur.

[https://dave.cheney.net/2016/04/27/dont-just-check-errors-handle-them-gracefully](https://dave.cheney.net/2016/04/27/dont-just-check-errors-handle-them-gracefully)

> In general, the call `f(x)` is responsible for reporting the attempted operation `f` and the argument value `x` as they relate to the context of the error. The caller is responsible for adding further information that it has but the call `f(x)` does not.

From [The Go Programming Language](https://www.amazon.com/dp/0134190440) book.

In practice, executing _"The caller is responsible for adding further information that it has but the call `f(x)` does not"_ is pretty difficult. The caller has no way of knowing if `x` is already captured by `f`. It's not unusual to end up with errors that contains chains of redundant information.

## Sample scenario [#](#sample-scenario-)

Let's take a look at a modified version of Dave Cheney's [ReadFile example](https://dave.cheney.net/2016/04/27/dont-just-check-errors-handle-them-gracefully) that reads the contents of a hidden `.settings.xml` file from a directory:

```go
package main

func main() {
  _, err := config.Read(os.Args[1])
  if err != nil {
    fmt.Printf("failed to read config from %s: %v\n", os.Args[1], err) // [1]
    os.Exit(1)
  }
}
```

```go
package config

func Read(dirPath string) ([]byte, error) {
  confPath := filepath.Join(dirPath, ".settings.xml")
  b, err := readFile(confPath)
  if err != nil {
    return fmt.Errorf("failed to read file from %s: %w", confPath, err) // [2]
  }
  return b, nil
}

func readFile(path string) ([]byte, error) {
  f, err := os.Open(path)
  if err != nil {
    return nil, fmt.Errorf("failed to open %s: %w", path, err) // [3]
  } 
  defer f.Close()
 
  b, err := ioutil.ReadAll(f)
  if err != nil {
    return nil, fmt.Errorf("failed to read %s: %w", path, err) // [4]
  }
  return b, nil
}
```

This approach wraps every possible error with additional context and results in the following blurb:

```
Error: failed to read config from /Users/abc: failed to read file from /Users/abc/.settings.xml: failed to open /Users/abc/.settings.xml: open /Users/abc/.settings.xml: no such file or directory
```

We're repeating the `/Users/abc/.settings.xml` path 3 times in the error.  
We can't omit the last path as it comes form `os.Open`. We can't omit the error from [1] either as it outlines the task that we're trying to perform.   
However, one of `"failed to read file from /Users/abc/.settings.xml"` [2] or `"failed to open /Users/abc/.settings.xml"` [3] is unnecessary.

## Recommendation [#](#recommendation-)

**Wrap only the errors coming from public function or methods. Otherwise, propagate them.**

This way we focus on the knowledge that's needed to perform a task, the interactions with the public interfaces, have additional contexts.  
Otherwise, the error message surfaces interactions that are implementation details, our package private functions, to perform a task which is information leakage to the reader.

In the example above, we'd modify [2] to just propagate the error since it's making a call to a package private function `readFile`. However, [1], [3], and [4] remain intact as they interact with `config.Read`,  `os.Open` and `ioutil.ReadAll` which are all public functions.

```go
package config

func Read(dirPath string) ([]byte, error) {
  confPath := filepath.Join(dirPath, ".settings.xml")
  b, err := readFile(confPath)
  if err != nil {
    return err // Propagate here instead of wrapping [2]
  }
  return b, nil
}

func readFile(path string) ([]byte, error) {
  f, err := os.Open(path)
  if err != nil {
    return nil, fmt.Errorf("failed to open %s: %w", path, err) // [3]
  } 
  defer f.Close()
 
  b, err := ioutil.ReadAll(f)
  if err != nil {
    return nil, fmt.Errorf("failed to read %s: %w", path, err) // [4]
  }
  return b, nil
}
```

The error message now becomes:

```
Error: failed to read config from /Users/abc: failed to open /Users/abc/.settings.xml: open /Users/abc/.settings.xml: no such file or directory
```
