---
layout: post
title: "A retrospective on productivity and (lack?) of quality with coding agents"
tagline: "Can we really eliminate code reviews?"
tags: [agents, engineering]
---

On one end of the spectrum, people are achieving tremendous feats of engineering, such as the massive [rewrite of Bun from Zig to Rust](https://bun.com/blog/bun-in-rust). Folks are pointing to achievements like this as a preview of the ["end of programming"](https://pauldix.com/the-end-of-programming) where humans no longer write or review most of the code themselves, but instead design mechanisms for context injection and verification such that their coding agents self-validate their own work.

> *What I mean by this is that I think the act of writing code manually <span class="text-highlight">and having other humans review it</span> to create useful, working software is headed for extinction. Or at the very least, it will be drowned out by the absolute deluge of useful, working software that will be created by agents, <span class="text-highlight">with humans reviewing only the end result, not the code itself.</span>*  
> – [The end of programming](https://pauldix.com/the-end-of-programming)

On the other end of the spectrum, the same article predicts that coding agents will produce "[...] a mountain of slop. Of buggy, useless, terrible, offensive software." Frankly, my experience since the tail end of 2025 resembles more of the latter. The rate of bugs, papercuts, and amorphous code changes being checked in has increased. At first glance, this is very odd. Given an army of tireless automated programmers, we should be able to [choose how many bugs we want](https://nolanlawson.com/2026/08/16/you-can-just-choose-how-many-bugs-you-want-now/). Yet, if we are truthful, I'd wager that by a significant margin, most of us in our professional environments [^1] have not achieved the expected combination of quality and productivity.

It's clear that we must work towards eliminating human-in-the-loop, such as asking another human to code review, because it's a bottleneck on productivity. However, I do not believe that every group can eliminate it today. This post is my attempt to understand:
- What distinguishes the groups that have achieved both high quality and productivity with coding agents? 
- Why I have not been able to replicate their outcomes in large engineering organizations?
- What would have to change for us to eliminate human code review at scale?

## Ingredients of quality

With coding agents, the throughput of code changes has already increased dramatically. However, what we really want is *high quality* programs. Improving quality lowers costs by reducing the time spent fixing bugs and reworking changes, while also minimizing delivery delays. This ultimately increases productivity. The reverse is not true.

> [...] *a defective part in an automobile is chargeable to management, not to sloppy workmanship. <span class="text-highlight">The fault is in the design, not workmanship.</span> Design is the function of management, not of the production worker.*  
> – [The Essential Deming](https://www.amazon.com/dp/0071790225)

Deming wrote this about car manufacturing, but I think the analogy is apt for the era of coding agents. The coding agent is the production worker, while the engineer prompting it is management. The engineer remains responsible for the **design**: the requirements, approach, exposed module contracts, invariants, and testing. It is through designs that we find _simple_ solutions, and simplicity allows a program to retain its quality as new changes accumulate:

> _Simplicity is the best strategy for scaling. When engineers think about how to solve a complex problem, the obvious answer is to design a complex solution, one with good asymptotics but high fixed overheads. If instead you look for ways to simplify the problem, that often leads to simple solutions with low overheads that work just as well. Simpler solutions scale better and are easier to maintain._  
> – [Russ Cox, People of ACM](https://www.acm.org/articles/people-of-acm/2026/russ-cox)

Even the most AI-pilled articles do not contradict this. Nobody who produces serious software vibe codes their changes. From the same article predicting the end of programming:

> *<span class="text-highlight">I’m able to give it requirements, **architecture** and instructions</span> for a feature I want to develop and it is able to create a fully functioning first version over multiple working hours with no further interaction from me.*

Designing a change that fits an existing program requires a **theory** of that program, as Peter Naur defines in ["Programming as Theory Building"](https://gwern.net/doc/cs/algorithm/1985-naur.pdf): 
1. What does each part of the program text mean in the real world? 
2. Why was this representation chosen over alternatives? 
3. How is a modification best incorporated into the program?

Zooming in to the last dimension of theory building, knowing how best to incorporate a change requires **good taste** in software design, which is built through a combination of knowledge and experience. For example, you and I likely share similar preferences if we first look to "make the change easy, then make the easy change", avoid dependency-injection frameworks, prefer stubs to mocks, accept a little duplication instead of adding a new dependency, prefer languages with errors as values, seek small interfaces for abstractions, follow John Ousterhout's guidance on comments, etc.  
I can imagine that, in the longer run, stronger LLMs and harnesses will consistently organize code better than I can, even when navigating the patterns of a byzantine program. _Today, however, I still add value by steering the agent toward better abstraction design and module decomposition, so that responsibility remains on my plate._

Without close alignment in theory among contributors to the software, we will inevitably introduce changes that hamper its simplicity and power. As complexity accumulates, future changes become harder to implement correctly, increasing defects and rework.

In conclusion, to produce high quality software, we need to (i) have a sound theory of the program, (ii) share the same definition of good among contributors, and (iii) ground each design in that theory as we iterate on the program.

## The north star

The recipe outlined in the article below resonated strongly with my own successful experience of building good software while benefiting from the productivity boost of agents:

> _Small <span class="text-highlight">high-trust</span> teams have an easy process they can adopt:_
> 1. _A human instructs a machine to make a change._
> 2. _The [same] human reviews the code, iterates with comments until they approve it._
> 3. _They push the change to production and deploy._  
>
> _There is still a human in the loop. [...]_  
> _Anecdotal evidence suggests this works for <span class="text-highlight">small teams</span>. With a team of nine at [exe.dev](https://exe.dev) we have been able to make it work. We spend a lot more time writing integration tests, e2e tests, building agent-based workflows for analyzing commits for safety or performance or usability bugs to minimize risk. [...] <span class="text-highlight">We also have had to be very selective about our colleagues and be intentional in our communication</span>. But we ship this way._  
> – [The agent principal-agent problem](https://crawshaw.io/blog/agent-principal-agent)

He does not pitch to eliminate human review entirely. Instead, we eliminate the need for a second human to review each change, while keeping responsibility with the person prompting the agent.

Fundamentally, there needs to be **trust** among all the peers contributing to the codebase. Once we have earned each other’s trust, we no longer need to read each other’s low-level code. I trust that you did the due diligence and that whatever is being merged fits our shared definition of quality. Go ahead and merge it! Design reviews are how we sync, while reviewing our own code helps maintain both its quality and our individual theories of the program.

Of course, as quoted above, we should invest along the way in mechanisms to enforce quality: context files, skills, linting, unit tests, integration tests, [QA tests](https://antirez.com/news/168), etc. However, all these mechanisms will inevitably be incomplete. At the bottommost layer, we still need to trust each other.

## Challenge of large organizations

A month ago, I joined a new team. Nobody should trust me yet to yolo merge changes because I do not have a good theory of the program. I need code reviews from teammates who have a much better understanding of how the program maps to the real world and why it is structured the way it is.

> _This is not tenable in low-trust environments, i.e. large companies. You have to trust your co-workers to start a conversation about architectural changes before they do it. No-one at BigCo trusts their colleagues to make sweeping changes to a service they "own"._  
> – [The agent principal-agent problem](https://crawshaw.io/blog/agent-principal-agent)

To create high quality software, you need a solid theory, taste, and designs.  
To go fast, you need trust amongst contributors.  
Trust is earned by demonstrating repeatedly we share the same definition of quality.

In my opinion, any management approach that assumes coding agents enable anyone to contribute effectively to any team’s codebase is doomed to produce low-quality software. Engineers within a team at BigCo are at different stages in developing both their taste and their theory of the program, while those outside the team face an even wider gap in sharing that theory.

We can achieve this dream state, even at BigCo! We just need to return to the fundamentals of good software engineering while trust is being earned.
1. Architectural changes and features need to have a design review upfront.
2. Keep your pull-requests small while you're trying to earn trust. A human still needs to review them.
3. Review your own changes first. We must shift the balance of effort back toward the author rather than the reviewer. This is the end state we need to reach anyway. Carefully read the exposed interfaces, tests, and critical paths in the generated code. Comment on the code review and have your agent iterate, and contribute the necessary harness mechanisms to improve future code generation for everyone.

Looking further ahead, I think a coding harness capable of creating and maintaining a truly _shared memory_ across sessions and contributors will eventually unlock tremendous productivity without sacrificing quality. Such a harness should be able to recognize and explain when a feature request does not fit the product, understand how the codebase should evolve, and make changes consistent with that direction. Until then, I’ll keep reviewing the code my agents generate to maintain quality.

[^1]: I work at a very large tech company.