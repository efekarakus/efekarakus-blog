---
layout: post
title: A Guide to Writing Code Comments
tags: [programming]
---

I recently read [A Philosophy of Software Design by John Ousterhoust](https://www.amazon.com/Philosophy-Software-Design-John-Ousterhout/dp/1732102201) and the chapters that stood out the 
most for me were about `/* code comments */`. Although there is a lot of good material out there on how to write
clean code, a concise guide for good in-code documentation is lacking.
Inspired by [A Guide to Naming Variables](https://a-nickels-worth.blogspot.com/2016/04/a-guide-to-naming-variables.html),
this post is my attempt at creating a digest of best-practices for commenting. This document
is a work-in-progress, please send me any constructive feedback on how to improve it.

## Commenting Tenets (Unless You Know Better Ones)
* _Describe things not obvious from the code_. If you can remove your comments through better code then do that.
* _Err on the side of commenting_. We are not always at our best. Writing clean code is difficult, when in doubt add a comment and seek feedback.
* _Complete the abstractions_. If users need to read the implementation in order to use your public API then the abstraction is leaked. Use comments to avoid surprises for the caller.

## Cookbook

### Describe things not obvious from the code
[DRY](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself) also applies to comments. 
Implementation comments (body of a function) can usually be replaced with better naming.
If you're documenting a data structure, interface, function, a good rule-of-thumb to follow 
is to **use different words than the entity described**[^1].

### Err on the side of commenting
We build systems with the assumption that anything can fail, so we try to make [recovery](http://roc.cs.berkeley.edu/roc_overview.html) as easy as possible. We should adopt a similar mindset with our code quality. Not everything
that we write will be clear, and if you think the code doesn't capture what's in your mind then add a comment[^1].
If a code reviewer raises clarification questions, it's a good sign for refactoring or documentation[^2][^3].

### Complete the abstractions 
The tenet is best applied to a _public_ function or method and the target audience is its users. Good things to cover in the comments are: contracts, side-effects, exceptions, parameters, and return values. A good example is the [strings.SplitAfter](https://golang.org/pkg/strings/#SplitAfter) function:
```go
// SplitAfter slices s into all substrings after each instance of sep and
// returns a slice of those substrings.
//
// If s does not contain sep and sep is not empty, SplitAfter returns
// a slice of length 1 whose only element is s.
//
// If sep is empty, SplitAfter splits after each UTF-8 sequence. If
// both s and sep are empty, SplitAfter returns an empty slice.
//
// It is equivalent to SplitAfterN with a count of -1.
func SplitAfter(s, sep string) []string
```
This comment is good because a user might assume that result will be `[]` when `sep` is not in `s`. Instead, the comment
squashes those assumptions by addressing edge-cases for the return value. You can't rename the parameters 
or function either to convey this information. Keep the user in mind while writing documentation[^4].

## Further Reading
[^1]: Chapters 12 & 13 from [A Philosophy of Software Design](https://www.amazon.com/Philosophy-Software-Design-John-Ousterhout/dp/1732102201) by John Ousterhoust
[^2]: [CodeAsDocumentation](https://www.martinfowler.com/bliki/CodeAsDocumentation.html) by Martin Fowler
[^3]: [Send code reviews to junior engineers](https://www.efekarakus.com/2019/03/16/send-code-reviews-to-junior-engineers.html) by Efe Karakus
[^4]: Go proverbs: [Documentation is for users.](https://www.youtube.com/watch?v=PAAkCSZUG1c&t=19m07s) by Rob Pike
[^5]: [What is Software Design?](http://www.developerdotstar.com/printable/mag/articles/reeves_design.html) by Jack W. Reeves

