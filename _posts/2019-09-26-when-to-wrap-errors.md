---
layout: post
title: When to wrap errors
categories: [golang]
---

## TL;DR [#](#tldr-)

Only wrap errors returned from public functions or methods. Otherwise, propagate them.

## Problem statement [#](#problem-statement-)

Go 1.13 introduced [error wrapping](https://golang.org/doc/go1.13#error_wrapping) to the standard library. Previously, you could use the [pkg/errors](https://godoc.org/github.com/pkg/errors) library to add additional context to an error.  Unfortunately, there is little guidance (that I could find) on when to wrap your errors besides wrapping them as soon as they occur:

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
The last path can't be avoided as it comes form `os.Open` so we can't get rid of that one. However, one of `"failed to read file from /Users/abc/.settings.xml"` [2] or `"failed to open /Users/abc/.settings.xml"` [3] is unnecessary.

## Recommendation [#](#recommendation-)

**Wrap only the errors coming from public function or methods. Otherwise, propagate them.**

This way we focus on the knowledge that's needed to perform a task, interactions with the public interfaces, have additional contexts.
Otherwise, the error message focuses on the order needed to perform a task which is information leakage.

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

