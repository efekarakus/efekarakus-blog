---
layout: post
title: 'An example of "a little copying is better than a little dependency"'
tags: [programming]
---

The gist of the Go proverb [“a little copying is better than a little dependency”](https://www.youtube.com/watch?v=PAAkCSZUG1c&t=568s) is to be careful when bringing new dependencies to our programs. Of course, taking [DRY](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself) or this proverb literally will lead to poor outcomes. But, I think being vigilant about dependencies and going through some [checklist](https://research.swtch.com/deps) is good advice.

In this post, we’re going to list why we removed an existing dependency ([moby/buildkit](https://github.com/moby/buildkit)) from the [aws/copilot-cli](https://github.com/aws/copilot-cli), and explore the mechanics of the process.

## Rational
First of all, buildkit is a perfectly fine module to depend on! But for us, the library only provided nice-to-have functionality that was low effort to rewrite and reduced our binary size. 

<span class="label t">optional</span> We use buildkit to parse a Dockerfile, and extract certain instructions like the ports exposed or container health check settings. If the parsing fails, it’s no big deal. We print a warning and the user can re-enter that information later.

<span class="label t">size</span> Today, the `darwin/amd64` executable is roughly 45MB.
```
$ ls -l bin/local/copilot-darwin-amd64 
... 47662160 Sep 17 10:10 bin/local/copilot-darwin-amd64
```

Doing a quick [prototype](https://gist.github.com/efekarakus/038e3e576cd66e159e83088fe68055d0) by commenting out the use of the library shows that we can save ~3MB of space.
```
$ ls -l bin/local/copilot-darwin-amd64 
... 44355104 Sep 17 10:13 bin/local/copilot-darwin-amd64
```
Not as big of a saving as I had hoped for but not bad either.

<span class="label t">cheap</span> Since we use only a small surface area of the library, it’s also relatively easy to replace the functionality. Since buildkit is open source, we can dive into the codebase and get a sense of how Dockerfiles are parsed.

## Mechanics
### Ensure compatibility in unit tests

Just like Rob Pike’s [`strconv.IsPrint`](https://cs.opensource.google/go/go/+/refs/tags/go1.17.1:src/strconv/quote_test.go;l=18) test example in the Go proverbs talk, we don’t depend on buildkit in the source files. Instead, we only import the library in our unit tests and ensure that our parsed outputs match buildkit's!

For example, in the [tests](https://github.com/aws/copilot-cli/blob/a4e703b2bdf1138d5ed97418298b8bfbd810439e/internal/pkg/docker/dockerfile/dockerfile_test.go#L258) for parsing `HEALTHCHECK [OPTIONS] CMD command ` instructions, we ensure that the `command` values match exactly. However, we don’t compare the `[OPTIONS]` because AWS Copilot uses different defaults than Docker.  
Similarly, for the exposed ports we ensure that Copilot detects the same ports in a Dockerfile as buildkit.

### Swap the logic
Finally, we have the fun part of replacing the parser. For Copilot, all we had to do was replacing the Dockerfile scanner with a custom version. Luckily, there is another great Go talk from Rob Pike on the topic: [Lexical Scanning in Go](https://www.youtube.com/watch?v=HxaD_trXwRE) that we can pair with [buildkit’s implementation](https://github.com/moby/buildkit/blob/7641cbf96184bd14b127d2565869e62c1827a1c9/frontend/dockerfile/parser/parser.go#L250).
Replacing the library resulted in roughly adding [240 lines of code](https://github.com/aws/copilot-cli/pull/2864/files#diff-5d7c4a8ec114d611950dd6d74a794dc64f8f22212a82a285fb45bde1ee8c362d).


## Takeaways
There can be some quick wins out there by duplicating a little bit of code.
Some further reading material:

* Russ Cox, ["Our Software Dependency Problem"](https://research.swtch.com/deps) January 2019. 
*  Niklaus Wirth, ["A plea for lean software."](http://people.inf.ethz.ch/~wirth/Articles/LeanSoftware.pdf) Computer 28.2 (1995): 64-68.