---
layout: post
title: 'Thoughts on client-side platforms'
tags: [design]
---

_This post explains the motivation for client-side platforms by situating it against components and managed platforms, describes challenges with building a system that's "leaky by design", and then lists design guidelines to tackle these challenges._ 

A platform is a collection of components on top of which many people can build programs, usually application programs [[1]](#1). AWS is well known [[2]](#2)[[3]](#3) for not building platforms, and instead delivering big components that can be composed together to build bespoke solutions:
> I think a couple players then decided they need to really get going and they just chose the wrong abstraction to build. They built too high in the stack as opposed to these building blocks like we built, that allowed developers to stitch them together however they saw fit.
> \- Andy Jassy

There are several disadvantages for _managed_ platforms:
* **Extensibility**. Platforms provide _complete_ solutions to clients.  As long as client needs are met, this focus on completeness results in a delightful user experience. However, eventually requirements will change and since clients can’t extend the platform, they lose the freedom to adapt their application to their customer requests.
![managed-platform](/assets/client-side-platforms-thoughts/managed-platform.svg){: .center-image }
<span class="center-image" style="text-align: center;"><i>Figure 1: User journey for managed platforms</i></span>

* **Agility**.  Since platforms provide a _consistent_ interface across their functionalities, this simpler API comes at the expense of delivery speed. Adding 1 new feature to the platform forces you to evaluate how it fits with the existing N other features, slowing you down significantly as your feature set grows [[4]](#4).

* **Efficiency**.    
  > Slow, powerful operations force the client who doesn’t want the power to pay more for the basic function.
  > \- Butler Lampson [[5]](#5)  
  {: .inline-blockquote}

  Platforms are a thick layer of abstraction. The additional features can result in the creation of unnecessary resources, resulting in a slower or more expensive experience for the client.  
  {: .after-blockquote}

Software is full of oppositions and some of the weaknesses of platforms are also their strengths:
* **Hiding undesirable properties**. Since components need to be re-usable across a wide range of clients, successful ones grow to have extremely large number of knobs [[6]](#6). Instead, platforms provide an opinionated view of how applications should be built and can hide properties that don’t fit their philosophy. Clients that share the same beliefs have a delightful experience using the product.

* **Consistency**.    
   > If you take 10 components off the shelf, you are putting 10 world views together, and the result will be a mess. No one is responsible for design integrity, and only the poor client is responsible for the whole thing working together.
   > \- Butler Lampson [[1]](#1)  
   {: .inline-blockquote}
	
   The learning curve is too long for clients building applications from primitive components. One of the contributing factors in the difficulty is this inconsistency between interfaces. Platforms take over this burden, and provide a more gradual developer experience by vending a consistent API on top of these components.
   {: .after-blockquote}

* **Completeness**. While components are flexible in their use, it’s left to the client to figure out how to compose them together to achieve their use cases. Learning about the best practices of a component and how to integrate them is not trivial. Instead, platforms vend complete solutions to problems allowing the client to focus on what differentiates their business.

An alternative to _managed_ platforms is _client-side_ platforms. A client-side platform’s interface is like a managed one, however the underlying components are visible and owned by the client instead.  For example, the product that I work on, [AWS Copilot](https://aws.github.io/copilot-cli/), creates resources in the customer’s AWS account while providing a platform-like experience for containerized microservices. 

The advantage of a client-side platform over a managed one is that there is an opportunity to mitigate one of its major concerns: _extensibility_.


![client-side-platform](/assets/client-side-platforms-thoughts/client-platform.svg){: .center-image }
<span class="center-image" style="text-align: center;"><i>Figure 2: User journey for client-side platforms</i></span>
{: .tab-once}

The developer experience starts off just like a managed platform, but once a client hits a functionality limit, they can drop down a level of abstraction and manage the exposed components themselves.  Therefore, clients can start with a great experience and over time end up at the same place as if they never used a platform to begin with. For example, Copilot manages all AWS resources via AWS CloudFormation stacks. If the properties surfaced by Copilot are not sufficient, clients have access to the created CloudFormation templates to manage the resources on their own.

This gain in flexibility comes at the cost of the following benefits provided by managed platforms:
* **Operations**. Since resources are created in the client’s account, the clients become responsible for the scalability, reliability, and resiliency of their applications. For example, if there is a surge in traffic, the client needs to configure autoscaling settings appropriately instead of leaving it to the platform to figure out how to scale their application. This means the interface for client-side platforms have to be more complicated than managed ones. 

*  **Lack of information hiding**. The platform is usually built with assumptions about the underlying data model. Exposing the internal layers means that clients can modify them and break those assumptions. For example, if a customer of Copilot manually removed the `"aws-copilot-*"` tags from their resources, then Copilot won’t be aware of these resources and leak them. Clients don't know of this coupling and it can be a source of confusion for why the platform isn’t behaving as expected. Exposing the internals of the system can be a source of instability for the platform.

## Design challenges
> A surprisingly hard problem is how to design a system that is “intentionally leaky” — where you can provide higher level functionality while still exposing internal layers that allow someone building on top of your component direct access to those lower layers.   
> \- Terry Crowley [[7]](#7)

> The onion principle: doing a simple task is simple, and if it’s less simple, you peel one layer off the onion. The more layers you peel off, the more you cry. — Bjarne Stroustrup


Client-side platforms are solutions that should be “leaky by design” [[7]](#7). In figure 2. ![](/assets/client-side-platforms-thoughts/client-platform-cliff.svg){: .sparkline}, clients that hit the limits of the platform have to <span style="color: #c92a2a;">acquire a lot of expertise</span> to use the next level of abstraction. If the platform is difficult to extend, then it will lead to poor user retention.  Instead, we'd like to provide a "staircase" experience ![](/assets/client-side-platforms-thoughts/client-platform-steps.svg){: .sparkline}, where clients are given several _extension points_ that expose just enough of the underlying components such that "peeling the onion" isn't too difficult. 

There are several challenges with achieving the staircase experience. First, we have to figure out how to provide a gradual ![](/assets/client-side-platforms-thoughts/gradual.svg){: .sparkline} developer experience where getting started is easy and adding advanced functionality remains relatively easy. Second, we need to decide where is the limit of the platform such that vended functionality stops and extension points ![](/assets/client-side-platforms-thoughts/staircase.svg){: .sparkline} begin. Finally, we have to figure out which one of these low-level capabilities we want to expose to clients and how.

## Techniques for discovering complexity

This section provides guidelines, mostly adapted from "Hints and Principles for Computer System Design." [[5]](#5) and Terry Crowley's [blog](https://terrycrowley.medium.com/), for tackling the design challenges around client-side platforms.

### From getting started ![](/assets/client-side-platforms-thoughts/gradual.svg){: .sparkline} to advanced functionality 

0. Hiding undesirable properties.
1. Smart defaults.
2. We aim for consistency to the best of our knowledge but not for completeness across layers -- minimum lovable product.
3. For advanced functionality: nested (composite) configuration and recommended actions.

### Drawing a boundary
> Don’t hide power. Leave it to the client. - Butler Lampson [[5]](#5)  

> Often a module that succeeds in doing one thing well becomes more elaborate and does several things. This is okay, as long as it continues to do its original job well. If you extend it too much, though, you’ll end up with a mess. Only good judgment can protect you from this. - Butler Lampson [[5]](#5)  

Operations and performance. Do not hide power.

Features in terms of additional usecases supported is where you decide where your limit should be.

Talk about maintainance cost of new integrations.

### Exposing internal layers
> The flaw in this approach is that it presumes that the designer of the programming language will build into the language most of the abstractions that users of the language will want. Such foresight is not given to many; and even if it were, a language containing so many built-in abstractions might well be so unwieldy as to be unusable. - Barbara Liskov



## Further material
<span id="1">[[1]](#1)</span> Lampson, Butler W. "Software components: Only the giants survive." Computer Systems. Springer, New York, NY, 2004. 137-145. [Link](https://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.14.9546&rep=rep1&type=pdf#page=133)  
<span id="2">[[2]](#2)</span> "AWS re:Invent 2021 - Keynote with Dr. Werner Vogels", YouTube, uploaded by Amazon Web Services, 2 Dec. 2021, [https://www.youtube.com/watch?v=8_Xs8Ik0h1w&t=3138s](https://www.youtube.com/watch?v=8_Xs8Ik0h1w&t=3138s)  
<span id="3">[[3]](#3)</span> "Overcoming the Capitalist's Dilemma, with Andy Jassy, CEO of Amazon Web Services", HBS, 1 Sep. 2020, [https://www.hbs.edu/forum-for-growth-and-innovation/podcasts/disruptive-voice/Pages/podcast-details.aspx?episode=15834284](https://www.hbs.edu/forum-for-growth-and-innovation/podcasts/disruptive-voice/Pages/podcast-details.aspx?episode=15834284)  
<span id="4">[[4]](#4)</span> Terry Crowley, "My $0.02 on Is Worse Better?", Medium, 7 Mar 2019, [https://medium.com/hackernoon/my-0-02-on-is-worse-better-e240784ed6a7](https://medium.com/hackernoon/my-0-02-on-is-worse-better-e240784ed6a7)  
<span id="5">[[5]](#5)</span> Lampson, Butler. "Hints and Principles for Computer System Design." arXiv preprint arXiv:2011.02455 (2020). [Link](https://arxiv.org/ftp/arxiv/papers/2011/2011.02455.pdf)  
<span id="6">[[6]](#6)</span> Pavlo, Andy [@andy_pavlo], "In every DBMS project he's started, Mike always said "no knobs" in the beginning. But it's easier said than done of course. Postgres has ~350 knobs. MySQL has ~550. This graph from @danavanaken shows their knob counts over the last 20 years. This is why @OtterTuneAI exists.", Twitter, 2 Dec. 2021,[https://twitter.com/andy_pavlo/status/1466403668933189636](https://twitter.com/andy_pavlo/status/1466403668933189636)  
<span id="7">[[7]](#7)</span>Terry Crowley, "Leaky by Design", Medium, 14 Dec. 2016, [https://medium.com/@terrycrowley/leaky-by-design-7b423142ece0#.qjytflxbs](https://medium.com/@terrycrowley/leaky-by-design-7b423142ece0#.qjytflxbs)  