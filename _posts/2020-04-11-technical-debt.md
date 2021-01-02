---
layout: post
title: Technical debt
tags: [technical debt]
favorite: true
---

> None of it is new; but sensible old ideas need to be repeated or silly new ones will get all the attention.   
\- Leslie Lamport

It’s shown that professional software engineers don’t have a shared understanding of the technical debt metaphor [[1]](#1). This post explores what technical debt is and how to tackle it.

Ward Cunningham originally coined the “technical debt” metaphor [[2]](#2)  in order to explain why sometimes it’s a good idea to rush software out of the door — to gain a better understanding of your domain — but then you have to eventually go back to your codebase and reflect that knowledge. Note that this definition does not condone writing poor quality code, it’s instead about shipping good code without a proper understanding of the problem in order to gain an understanding.

A debt is composed of two components: a principal and interest. The principal is “how much is it going to cost us to replace this decision?”. The interest is “how much will it slow down the development of other features until the replacement is implemented?”.

The metaphor is helpful while discussing the tradeoffs of a design or to explain to business why a task might take longer than expected the second time around.

Steve McConnell’s definition [[3]](#3) goes beyond the analogy and makes it easier to see debt in the codebase:


> A design or construction approach that’s expedient in the short term but that creates a technical context in which **the same work** will cost more to do later than it would cost to do now (including increased cost over time).


By cost, we’re talking about development time. An increase in time to market results in wasted engineering cost and possibly not capturing the market because of competitors. This definition mentions the “same work” costing more. So if you had to add a similar feature to the codebase, will it be more painful the second time around? 

Now that we are aware of how we can spot debt in the codebase, it’s also important to be aware of the types of technical debts [[3]](#3)[[4]](#4) that exist so that we know which ones are acceptable and unacceptable.

1.  <span class="label" style="background-color: #FFF1B0; font-weight: 500;">unintentional</span> debt: we tried our best but we weren’t aware of coding best practices and resulted in lower quality work. 
2.  <span class="label" style="background-color: #66FFDD; font-weight: 500;">intentional</span>  and <span class="label" style="background-color: #FF80FD;  color: white; font-weight: 500;">reckless</span> debt: we opt in for messy code to save time. We know that we can do better but decide to take a shortcut and merge our changes without seeking advice.
3.  <span class="label" style="background-color: #66FFDD; font-weight: 500;">intentional</span> and <span class="label" style="background-color: #7373FF; color: white; font-weight: 500;">prudent</span> debt: we took a *design decision* that’s not the best possible solution on purpose because it’s a [two-way door](https://www.sec.gov/Archives/edgar/data/1018724/000119312517120198/d373368dex991.htm) and the benefits will overweigh the principal and interests.

In an ideal world, we’d only have <span class="label" style="background-color: #66FFDD; font-weight: 500;">intentional</span><span class="label" style="background-color: #7373FF; color: white; font-weight: 500;">prudent</span> debts, however realistically we will always have  <span class="label" style="background-color: #FFF1B0; font-weight: 500;">unintentional</span>  debts as we’re always learning. We must avoid <span class="label" style="background-color: #66FFDD; font-weight: 500;">intentional</span><span class="label" style="background-color: #FF80FD;  color: white; font-weight: 500;">reckless</span> debts.

## Managing technical debt

The goal is *not* to have any debt, instead it’s to be at a reasonable level. Shifting whole sprints to only paying debt is considered unproductive [[3]](#3), instead the recommended approach is to break the work into smaller pieces and then including debt reduction to the regular team flow.

Unfortunately we’ll always introduce <span class="label" style="background-color: #FFF1B0; font-weight: 500;">unintentional</span>  debt, but we can reduce the rate at which we introduce them by learning best practices and sharing with each other.  

We should aim at removing all <span class="label" style="background-color: #66FFDD; font-weight: 500;">intentional</span><span class="label" style="background-color: #FF80FD;  color: white; font-weight: 500;">reckless</span> debts during code reviews by insisting on high standards for ourselves and others. Usually the gain is not worth the cost. By creating a culture where giving and accepting feedback is comfortable we can push back against this debt.  

For design decisions that will result in <span class="label" style="background-color: #66FFDD; font-weight: 500;">intentional</span><span class="label" style="background-color: #7373FF; color: white; font-weight: 500;">prudent</span> debts, it’s important that we maintain a culture of [2-way doors](https://www.sec.gov/Archives/edgar/data/1018724/000119312517120198/d373368dex991.htm) and high velocity but balance it out with the following two questions:

1. How much will it cost to replace this decision?
2. How much will this implementation slow down other work until we retrofit the good path?

If we can execute a design so that the code for the reversible decisions are isolated and easy to replace, then the cost of question 2. becomes zero and we’re only left with the cost of question 1.

## Further reading

<span id="1">[[1]](#1)</span> 
Ernst, Neil A., et al. "Measure it? manage it? ignore it? software practitioners and technical debt." *Proceedings of the 2015 10th Joint Meeting on Foundations of Software Engineering*. 2015. [https://www.neilernst.net/papers/fse15.pdf](https://www.neilernst.net/papers/fse15.pdf).

<span id="2">[[2]](#2)</span>
Cunningham, Ward. “Ward Explains Debt Metaphor.” *Wiki.c2.Com*, [http://wiki.c2.com/?WardExplainsDebtMetaphor](http://wiki.c2.com/?WardExplainsDebtMetaphor).

<span id="3">[[3]](#3)</span>
McConnell, Steve. “Managing Technical Debt.” *Construx*, June 2008, [www.construx.com/resources/whitepaper-managing-technical-debt/](http://www.construx.com/resources/whitepaper-managing-technical-debt/).

<span id="4">[[4]](#4)</span>
Fowler, Martin. “TechnicalDebtQuadrant”, martingFowler.com, October 2009, [https://martinfowler.com/bliki/TechnicalDebtQuadrant.html](https://martinfowler.com/bliki/TechnicalDebtQuadrant.html).
