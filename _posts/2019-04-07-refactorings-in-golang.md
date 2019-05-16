---
layout: post
title: Refactorings in the Go Programming Language
categories: [refactoring, golang]
---

I'm a big fan of [Martin Fowler's refactoring book](https://refactoring.com/). It is essentially a large [catalog](https://refactoring.com/catalog/) of various refactorings with an example, motivation, and several how-to steps for each one. After reading the first edition a few years ago, I thought it made me a better software engineer. I developed better coding habits and I feel like I deliver results faster and with higher quality than before. I highly recommend other engineers to get themselves a copy.

The first edition's examples were in Java and now the second edition is in JavaScript. I'll try to collect similar refactorings from my experiences but for the [Go](https://golang.org/) programming language.

I started programming in Go in March 2019, so some of these refactorings might change over time as I become more familiar with the language. However, since I want to become an expert in Go I thought it would be a good learning experience for me and hopefully others. So far, I don't think that Go is _that_ different than other popular languages but there are certain primitives, like [interfaces](https://golang.org/doc/effective_go.html#interfaces_and_types), that are powerful and provide different ways of doing these refactorings. I'll try to focus on only refactorings that leverage unique aspects of Go.

> So we need to tell the rest of the world how good software should be written. Good software, composable software, software that is amenable to change, and show them how to do it, using Go. And this starts with you.
> 
> ----
> [SOLID Go Design by Dave Cheney](https://dave.cheney.net/2016/08/20/solid-go-design)

I'm hoping that this will be my small part in helping Go developers build programs that are designed to last.

## Catalog [#](#catalog-)

{% for category in site.categories %}
  {% if category[0] == "refactoring" %}
  <ul class="post-list">
    {% for post in category[1] %}
      {% if post.id != page.id %}
      <li>
        <a class="post-link" href="{{ post.url | relative_url }}">
          {{ post.title | escape }}
        </a>
        {%- assign date_format = site.minima.date_format | default: "%b %-d, %Y" -%}
        <span class="post-meta">{{ post.date | date: date_format }}</span>
        {%- if site.show_excerpts -%}
          {{ post.excerpt }}
        {%- endif -%}
      </li>
      {% endif %}
    {% endfor %}
  </ul>
  {% endif %}
{% endfor %}
