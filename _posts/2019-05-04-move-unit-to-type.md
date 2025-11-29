---
layout: post
title: Move a variable's unit to a type
tagline: "Use custom types to encode units of measurement at compile time, making code more concise while preserving clarity."
categories: [refactoring, golang]
---

```go
// before
const paddingInPixels = 10

// after
type pixels int
const padding pixels = 10
```

## Scenario [#](#scenario-)
You need to define a variable that has a "hidden" unit attached to it. Here is an example based on the 
[CSS translate function](https://developer.mozilla.org/en-US/docs/Web/CSS/transform-function/translate):
```go
// Translate repositions an HTML element  in the horizontal and vertical directions.
// tx and ty represent the new x and y coordinates in pixels.
func (el *Element) Translate(tx, ty int)
```
This code is fine. The variable names are concise, and after reading the comments 
the reader has the knowledge that `tx` and `ty` are in pixels as opposed to em or centimeters. 

Another common paradigm is to move the unit to the variable's name.
```go
// Translate repositions an HTML element in the horizontal and vertical directions.
func (el *Element) Translate(txInPixels, tyInPixels int)
```
I prefer the latter approach as comments should be used to
describe things that aren't obvious from the code. In this scenario, we can make the unit
obvious in the code so we should remove it out of the comments.

## A Go alternative [#](#a-go-alternative-)
In Go we can have the luxury of keeping the variable name concise while maintaining the
unit information.
```go
type pixels int

// Translate repositions an HTML element in the horizontal and vertical directions.
func (el *Element) Translate(tx, ty pixels)
```
This is honestly just a nitpick, but it does seem to keep the body of the function neater.

Categories [refactoring]({% post_url 2019-04-07-refactorings-in-golang %})
