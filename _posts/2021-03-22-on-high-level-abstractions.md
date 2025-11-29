---
layout: post
title: "On high level abstractions"
tagline: "Good abstractions hide what's undesirable and expose what's powerful."
tags: [design, programming]
---
> When a low level of abstraction allows something to be done quickly, higher levels should not bury this power inside something more general. **The purpose of abstractions is to conceal _undesirable_ properties; desirable ones should not be hidden.** Sometimes, of course, an abstraction is multiplexing a resource, and this necessarily has some cost. But it should be possible to deliver all or nearly all of it to a single client with only slight loss of performance.  
> \- Butler W. Lampson [[1]](#1)

I love the definition above especially applied to infrastructure abstractions. For example, when launching a set of containers on [AWS Fargate](https://aws.amazon.com/fargate/), a higher level abstraction, instead of EC2 instances, a lower level abstraction, you don’t have to worry about several undesirable properties: scaling, patching your instances, isolating your containers.   
An additional example is the product that I work on, [AWS Copilot](https://aws.github.io/copilot-cli/), that operates at an even higher level of abstraction. It multiplexes several AWS services together: Route53, ACM, ELB, ECS to form a REST API. The generated [manifest](https://aws.github.io/copilot-cli/docs/manifest/lb-web-service/) file conceals any low-level properties that is not relevant to building web applications.

Most foundational AWS services fit into the bucket of keeping interfaces to be _fast_ rather than more general or powerful and _leaving to the client_ to mix and match to form their own higher level abstractions:
> It is much better to have basic operations executed quickly than more powerful ones that are slower. The trouble with slow, powerful operations is that the client who doesn’t want the power pays more for the basic function. Usually it turns out that the powerful operations is not the right one.

To build the right high level abstraction, we need to let time pass and gain a better understanding of the domain. Once patterns emerge, we can extract them into their own abstractions. The right high level abstraction is delightful, it keeps things simpler only for a nominal cost. A high level abstraction can still pass control back to the client to provide flexibility while maintaining simplicity. For example, with AWS Copilot users can take control of the generated AWS CloudFormation templates to customize their service stacks.

<span id="1">[[1]](#1)</span> Lampson, Butler W. [“Hints for computer system design.”](https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/acrobat-17.pdf) Proceedings of the ninth ACM symposium on Operating systems principles. 1983.