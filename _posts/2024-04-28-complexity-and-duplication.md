---
layout: post
title: 'Complexity and duplication'
tags: [software engineering]
---

At large companies like Amazon, it’s inevitable that multiple independent teams will try to solve the same, or a closely related, problem $$P$$. One approach that optimizes for time-to-market is for each team to independently make decisions, build, and deliver software that solve for $$P$$. At Amazon, folks refer to the “bias for action” leadership principle when a team needs to act fast:

> Speed matters in business. Many decisions and actions are reversible and do not need extensive study. We value calculated risk taking.

While launching a solution as fast as possible is greatly desirable, we tend to underestimate the long term cost of duplication and its impact on sustained improvements. 

### Why does speed matter in business?
**The need to _launch_.** We build minimum viable products in order to validate our hypotheses, i.e. what we think customers want, with real customer data. We aim to learn as fast as possible what customers actually need while minimizing any wasted engineering efforts along the way. 

> All projects are vulnerable to unpredictable shocks, with their vulnerability growing as time passes.— Bent Flyvbjerg and Dan Gardner, [How Big Things Get Done](https://www.amazon.com/How-Big-Things-Get-Done/dp/0593239512).

Delivering a project as soon as possible also shields it from _black swan_ events. For example, a re-organization or sudden budget cuts within a large company can easily switch the ownership or halt a project altogether if it has not been delivered yet.

**The need for _sustained_ launches.** What we really want is for speed to be viewed as a “feature” by our customers. They need to know that our solutions are not only reliable but will also improve faster than anyone else’s. 

> […] go out there and have huge dreams, then show up to work the next morning and relentlessly incrementally achieve them. — Luiz André Barroso, [The Roofshot Manifesto](https://fontoura.org/papers/barroso.pdf).

![headcount allocation over time](/assets/duplication/landings-improvements.png){: style="float: left; margin: 0px 15px 0px 0px;" width="150"}Imagine we can improve our product by 30% every quarter, then in 2 ¼ years we would achieve over 10x improvement. Additionally, our customers would receive these improvements gradually over time instead of waiting two years for a potential step function improvement. 

### What is the cost of duplication?
While duplication across teams helps with (i) the time to initial launch, in this section we’ll explore how it impairs (ii) the delivery of sustained launches.

**Opportunity loss.** Imagine that within an organization there are 3 different teams each with 4 headcount that are all working on the same, or related, problem. We’re missing the opportunity to use two of these teams (i.e., 8 people) to work on different problem(s) and deliver new user experiences for our customers. Ensuring that our resources within the organization solve different problems is a surefire way of working faster to improve our product. At a minimum, if there will be duplication we need to think and address how we can make our software easy to decommission. 

**Deprecations are inevitable.**  

> Even at huge profitable companies, in some corners you'll occasionally find an understaffed project sliding deeper and deeper into tech debt. Users may still love it, and it may even be net profitable, but not profitable enough to pay for the additional engineering time to dig it out. Such a project is destined to die, and the only question is when. The answer is "whenever some executive finally notices." — Avery Pennarun, [Tech debt metaphor maximalism](https://apenwarr.ca/log/20230605).

I've experienced two reorganizations characterized by similar patterns. Public-facing duplicated projects, even those with devoted customers, are inevitably reduced to operational maintenance if their profitability is only marginal. Resources from these less lucrative projects can be redirected to more profitable ones lacking the headcount to accelerate innovation or to finance new ambitious bets. Meanwhile, internal projects lacking external revenue are destined to merge as they merely incur costs for the organization.

**Removing software is hard.** Let’s start by analyzing the cost associated with deprecating internal projects where owners have the affordance of modifying the client code, and therefore the opportunity to decomission their projects without impacting dependents.

{: style="overflow: auto; display: block;"}
![feature overlap](/assets/duplication/feature-overlap.png){: style="float: left; margin: 0px 15px 0px 0px;" width="80"} If the active project, say $$Proj_B$$, has already overlapping functionality as the project we are aiming to deprecate, say $$Proj_A$$, then the cost can be approximated as the sum of refactors across all client codebases to swap the dependency from $$Proj_A$$ to $$Proj_B$$. If a client did not isolate and wrap the $$Proj_A$$ dependency in a separate module, then the cost of this refactor can be quite high.

{: style="clear: both; overflow: auto; display: block;"}
![feature discrepancy](/assets/duplication/feature-discrepancy.png){: style="float: left; margin: 0px 15px 0px 10px;" width="70"} Unfortunately, the more realistic scenario is that two projects won’t be solving identical problems but tangentially related ones. Therefore, it’s more likely that there won’t be a mapping for all of the functionality in $$Proj_A$$ to $$Proj_B$$.

{: style="clear: both; overflow: auto; display: block;"}
![closing the gap](/assets/duplication/adding-missing-features.png){: style="float: left; margin: 0px 15px 0px 10px;" width="70"} If the missing functionality will benefit broadly $$Proj_B$$’s clients, then we can consider adding the missing features to it.  

{: style="clear: both; overflow: auto; display: block;"}
![pivot](/assets/duplication/pivot-proj.png){: style="float: left; margin: 0px 15px 0px 10px;" width="70"} Alternatively, we can progressively refactor clients to use as much of the overlapping functionality in $$Proj_B$$ as they can, and pivot $$Proj_A$$ to support only the remaining niche use cases.  

{: style="clear: both; overflow: auto; display: block;"}
Finally, we can decide to not retrofit the missing functionality at all and push the burden of building the missing functionality to the clients. In any case, for this scenario, in addition to the refactoring cost, somebody must also pay the cost of closing the gap between the two projects. 

Finally, deprecations are emotionally charged. There will be managers that lose impact, engineering teams that have to detach from beloved projects, so creating alignment on which project gets to survive even with impartial usage data is an extremely unpleasant and time consuming task.

**“Keep the lights on” is just a waste of energy.** For external projects where we cannot do client-side code changes to swap a dependency, the common solution is to move them into maintenance. Sadly, these projects incur ongoing cost as they have to continue to reply to customer issues, update their codebases as bugs are discovered or as the environment around them evolves, and finally release the changes via esoteric delivery pipelines. For example, a library dependency can announce an “end-of-support” date which means that there won’t be any security patches released anymore and the project has to upgrade to a newer major version of the library.

### Complexity is the enemy
> Code is a liability not an asset. — Anonymous


**Simplicity has larger impact.** Complexity is the enemy. We can arrive at greatly simpler solutions by willing 

> Consensus means everyone is heard and understood, and all concerns are addressed (even those not treated as blocking), and the team finds the outcome reasonable. Consensus does not mean everyone agrees completely. — The Rust Language Design Team
**Think slow, act fast.** Need to seek diverse opinions. Consensus means addressing everyones feedback while still leaving the 2-pizza team as the final decision maker.


---- 
One needs to “think slow, but act fast” - i.e. the best time to figure out whether to duplicate or deliver is in the design. And the duplication discussion needs to seek diverse opinions.