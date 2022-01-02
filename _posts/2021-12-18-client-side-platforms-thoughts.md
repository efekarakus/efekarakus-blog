---
layout: post
title: 'Thoughts on client-side platforms'
tags: [design]
---

_This post explains the motivation for client-side platforms by situating it against composable components and managed platforms, describes challenges with building such systems, and then lists design guidelines to tackle these challenges._ 

A platform is a collection of components on top of which many people can build programs, usually application programs [[1]](#1). AWS is well known [[2]](#2)[[3]](#3) for not building platforms, and instead delivering big components that can be composed together to build bespoke solutions:
> I think a couple players then decided they need to really get going and they just chose the wrong abstraction to build. They built too high in the stack as opposed to these building blocks like we built, that allowed developers to stitch them together however they saw fit.
> \- Andy Jassy

There are several disadvantages for _managed_ platforms:
* **Extensibility**. Platforms provide _complete_ solutions that cannot be extended. While the platform meets the client's needs, this focus on completeness results in a delightful user experience. However, eventually new functional requirements emerge and without extension points it becomes difficult for the client to adapt their application.
![managed-platform](/assets/client-side-platforms-thoughts/managed-platform.svg){: .center-image }
<span class="center-image" style="text-align: center;"><i>Figure 1: User journey for managed platforms</i></span>

* **Agility**.  A platform's strength is providing a _consistent_ interface across their functionalities, this simpler API comes at the expense of delivery speed. Adding 1 new feature to the platform forces you to evaluate how it fits with the existing N other features, slowing you down significantly as your feature set grows [[4]](#4).

* **Efficiency**.    
  > Slow, powerful operations force the client who doesn’t want the power to pay more for the basic function.
  > \- Butler Lampson [[5]](#5)  
  {: .inline-blockquote}

  Platforms are a thick layer of abstraction where the additional unwanted features can result in the creation of unnecessary resources. Consequently, resulting in a slower or more expensive experience for the client.  
  {: .after-blockquote}

Software is full of oppositions and some of the weaknesses of platforms are also their strengths:
* **Hiding undesirable properties**. Since components need to be re-usable across a wide range of clients, successful ones grow to have extremely large number of knobs [[6]](#6). Instead, platforms provide an opinionated view of how applications should be built and can hide properties that don’t fit their philosophy. Clients that share the same beliefs have a delightful experience using the product.

* **Consistency**.    
   > If you take 10 components off the shelf, you are putting 10 world views together, and the result will be a mess. No one is responsible for design integrity, and only the poor client is responsible for the whole thing working together.
   > \- Butler Lampson [[1]](#1)  
   {: .inline-blockquote}
	
   The learning curve is too long for clients building applications from primitive components. One of the contributing factors in the difficulty is this inconsistency between interfaces. Platforms take over this burden. They provide a more gradual developer experience by vending a consistent API on top of these components.
   {: .after-blockquote}

* **Completeness**. While components are flexible in their use, it’s left to the client to figure out how to compose them together to achieve their use cases. Learning about the best practices of a component and how to integrate them is not trivial. Instead, platforms vend complete solutions to problems allowing the client to focus on what differentiates their business.

An alternative to _managed_ platforms is _client-side_ platforms. A client-side platform’s interface is like a managed one, however the underlying components are visible and owned by the client instead.  For example, the product that I work on, [AWS Copilot](https://aws.github.io/copilot-cli/), creates resources in the customer’s AWS account while providing a platform-like experience for containerized microservices. 

The primary advantage of a client-side platform over a managed one is that there is an opportunity to mitigate one of its major concerns: _extensibility_.


![client-side-platform](/assets/client-side-platforms-thoughts/client-platform.svg){: .center-image }
<span class="center-image" style="text-align: center;"><i>Figure 2: User journey for client-side platforms</i></span>
{: .tab-once}

The developer experience starts off just like a managed platform, but once a client hits a functionality limit, they can drop down a level of abstraction and manage the exposed components themselves. Therefore, clients can start with a great experience and over time end up at the same place as if they never used a platform to begin with. For example, Copilot manages all resources via AWS CloudFormation stacks. If the properties surfaced by Copilot are not sufficient, clients have access to the generated CloudFormation templates to manage the resources on their own.  

A secondary advantage is an increase in _agility_. It's faster to deliver the same feature client-side compared to a managed service. Let's compare what it takes to expose an internal component property, such as ECS's [`secrets`](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/specifying-sensitive-data-secrets.html) field, for a client-side tool like Copilot vs a service that would sit on top of ECS. As an end-user tool, client-side platforms don't have to worry about any dependencies. All communication for the feature remains within the team. On the other hand, a managed service would need to communicate across several teams: control plane, data plane, upstream dependencies (console, SDKs, CloudFormation). The feature is also more difficult to implement as the client's secret lives in the client's AWS account whereas the running ECS tasks are in the service's account. Finally, the managed service has to build operational visibility with dashboards, monitors, and alarms. 

This gain in flexibility comes at the cost of the following benefits provided by managed platforms:
* **Operations**. Since resources are created in the client’s account, the clients become responsible for the scalability, reliability, and resiliency of their applications. For example, if there is a surge in traffic, the client needs to configure autoscaling settings appropriately instead of leaving it to the platform to figure out how to scale out. This means the interface for client-side platforms have to be more complicated than managed ones. 

*  **Lack of information hiding**. The platform is usually built with assumptions about the underlying data model and exposing the internal layers means that clients can modify them and break those assumptions. For example, if a customer of Copilot manually removed the `"aws-copilot-*"` tags from their resources, then Copilot won’t be able to find them and ultimately leak these resources. Clients aren't aware of this coupling, and it can be a source of confusion for why the platform isn’t behaving as expected. Exposing the internals of the system can be a source of instability for the platform.

## Design challenges
> A surprisingly hard problem is how to design a system that is “intentionally leaky” — where you can provide higher level functionality while still exposing internal layers that allow someone building on top of your component direct access to those lower layers.   
> \- Terry Crowley [[7]](#7)

> The onion principle: doing a simple task is simple, and if it’s less simple, you peel one layer off the onion. The more layers you peel off, the more you cry. — Bjarne Stroustrup


Client-side platforms are solutions that should be “leaky by design” [[7]](#7). In figure 2. ![](/assets/client-side-platforms-thoughts/client-platform-cliff.svg){: .sparkline}, clients that hit the limits of the platform have to <span style="color: #c92a2a;">acquire a lot of expertise</span> to use the next level of abstraction. If the platform is difficult to extend, then it will lead to poor user retention.  Instead, we'd like to provide a "staircase" experience ![](/assets/client-side-platforms-thoughts/client-platform-steps.svg){: .sparkline}, where clients are given several _extension points_ that expose just enough of the underlying components such that "peeling the onion" isn't too painful. 

There are several challenges with achieving the staircase experience. First, we have to figure out how to provide a gradual ![](/assets/client-side-platforms-thoughts/gradual.svg){: .sparkline} developer experience where getting started is easy and using advanced functionality remains relatively easy. Second, we need to decide where is the limit of the platform such that vended functionality stops and extension points ![](/assets/client-side-platforms-thoughts/staircase.svg){: .sparkline} begin. Finally, we have to figure out which one of these low-level capabilities we want to expose to clients and how.

## Techniques for discovering complexity

### From getting started ![](/assets/client-side-platforms-thoughts/gradual.svg){: .sparkline} to advanced functionality 

Client-side platforms provide opinionated abstractions. The first step in making getting started easy is to **have a point of view**. It's not that the platform's viewpoint is more correct than another, but that it's more convenient for some purpose [[5]](#5). For example, the Copilot team decided to default to favoring cost over scalability for its abstractions. By default, tasks are launched in public subnets secured with security groups, the client has to opt-in to the creation of NAT gateways and placement in private subnets if they have compliance or scalability reasons. It's perfectly reasonable to take the opposite stance and aim for scalability first. It just depends who the platform is for.

**Remove any undesirable properties** that are not relevant to the opinion. For example, Copilot's `Worker Service` abstraction does not expose fields from the underlying ECS task definition such as `PortMappings` because a queue-processing service should not accept incoming connections.  
Another set of undesirable properties are fields that become unusable when two components integrate with each other. For example, when connecting an Application Load Balancer with an ECS service, the target group's `port` field is not applicable [[8]](#8). 

**Populate options with best guesses**. Pre-fill as many options as possible by guessing the client's intent. For example, Copilot parses the the client's `Dockerfile` to autofill configuration such as the container's `port` and `healthcheck` settings.

**Suggest follow-up actions**. In order to slowly introduce clients to advanced functionality, recommend follow-up actions to users. For example, when a user creates a service with `copilot svc init`, Copilot hints to the client that more configuration is available at `path/to/manifest.yml` and they can run `copilot svc deploy` to update their service.

### Drawing a boundary
> Don’t hide power. Leave it to the client. - Butler Lampson

**Operations and performance are desirable properties**. Since client-side platforms can't control the client's application once its running, they have to surface settings to help clients operate applications on their own. However, they can provide smart defaults and visibility into their applications. TODO: need to expand on what we mean by operational configurations (availability, deployments, provisioning, emergency response) (availability, latency, performance, efficiency, change management, monitoring, emergency response, and capacity planning) (https://sre.google/sre-book/introduction/)

Operations and performance. Do not hide power.

Features in terms of additional usecases supported is where you decide where your limit should be.

Talk about maintainance cost of new integrations.

### Exposing internal layers
> The flaw in this approach is that it presumes that the designer of the programming language will build into the language most of the abstractions that users of the language will want. Such foresight is not given to many; and even if it were, a language containing so many built-in abstractions might well be so unwieldy as to be unusable. - Barbara Liskov

It's more important to have reflexive features rather than getting the extension points right.

## Further material
<span id="1">[[1]](#1)</span> Lampson, Butler W. "Software components: Only the giants survive." Computer Systems. Springer, New York, NY, 2004. 137-145. [Link](https://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.14.9546&rep=rep1&type=pdf#page=133)  
<span id="2">[[2]](#2)</span> "AWS re:Invent 2021 - Keynote with Dr. Werner Vogels", YouTube, uploaded by Amazon Web Services, 2 Dec. 2021, [https://www.youtube.com/watch?v=8_Xs8Ik0h1w&t=3138s](https://www.youtube.com/watch?v=8_Xs8Ik0h1w&t=3138s)  
<span id="3">[[3]](#3)</span> "Overcoming the Capitalist's Dilemma, with Andy Jassy, CEO of Amazon Web Services", HBS, 1 Sep. 2020, [https://www.hbs.edu/forum-for-growth-and-innovation/podcasts/disruptive-voice/Pages/podcast-details.aspx?episode=15834284](https://www.hbs.edu/forum-for-growth-and-innovation/podcasts/disruptive-voice/Pages/podcast-details.aspx?episode=15834284)  
<span id="4">[[4]](#4)</span> Terry Crowley, "My $0.02 on Is Worse Better?", Medium, 7 Mar 2019, [https://medium.com/hackernoon/my-0-02-on-is-worse-better-e240784ed6a7](https://medium.com/hackernoon/my-0-02-on-is-worse-better-e240784ed6a7)  
<span id="5">[[5]](#5)</span> Lampson, Butler. "Hints and Principles for Computer System Design." arXiv preprint arXiv:2011.02455 (2020). [Link](https://arxiv.org/ftp/arxiv/papers/2011/2011.02455.pdf)  
<span id="6">[[6]](#6)</span> Pavlo, Andy [@andy_pavlo], "In every DBMS project he's started, Mike always said "no knobs" in the beginning. But it's easier said than done of course. Postgres has ~350 knobs. MySQL has ~550. This graph from @danavanaken shows their knob counts over the last 20 years. This is why @OtterTuneAI exists.", Twitter, 2 Dec. 2021,[https://twitter.com/andy_pavlo/status/1466403668933189636](https://twitter.com/andy_pavlo/status/1466403668933189636)  
<span id="7">[[7]](#7)</span>Terry Crowley, "Leaky by Design", Medium, 14 Dec. 2016, [https://medium.com/@terrycrowley/leaky-by-design-7b423142ece0#.qjytflxbs](https://medium.com/@terrycrowley/leaky-by-design-7b423142ece0#.qjytflxbs)  
<span id="8">[[8]](#8)</span> [https://stackoverflow.com/a/42823808](https://stackoverflow.com/a/42823808)