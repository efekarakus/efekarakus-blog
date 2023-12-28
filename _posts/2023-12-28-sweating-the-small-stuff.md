---
layout: post
title: 'Sweating the small stuff'
tags: [planning]
image: /assets/sweating-the-small-stuff/headcount-allocation.png
---

> In my life as an architect, I find that the single thing which inhibits young professionals, new students most severely, is their acceptance of standards that are too low. If I ask a student whether her design is as good as Chartres, she often smiles tolerantly at me as if to say, “Of course not, that isn’t what I am trying to do… I could never do that”.  
> Then, I express my disagreement and tell her: “**That standard _must_ be our standard**. If you are going to be a builder, no other standard is worthwhile. That is what I expect of myself in my own buildings, and it is what I expect of my students.”  Gradually, I show the students that they have a _right_ to ask this of themselves, and _must_ ask this of themselves. Once that level of standard is in their minds, they will be able to figure out, for themselves, how to do better, how to make something that is as profound as that.  
>  
> Two things emanate from this changed standard. First the work becomes more fun. It is deeper, it never gets tiresome or boring. One’s work becomes a lifelong work, and one keeps trying and trying. But secondly, it does change what people are trying to do. It takes away from them the everyday, lower-level aspiration that is purely technical in nature, and replaces it with something deep, which will make a real difference to all of us that inhabit the earth.  
> —Christopher Alexander

At Amazon, we refer to any usability frictions or, more broadly, small product issues as [_paper cuts_](https://youtu.be/DcWqzZ3I2cY?feature=shared&t=5893). A few paper cuts aren't particularly damaging, but a thousand (paper) cuts cause significant customer pain. Fixing paper cuts and iterating on existing features is not only important to create experiences that customers are enthusiastic about, but at a personal level, it elevates our work to something we’re proud of.

**For single independent teams**, I found the most effective mechanism to tackle paper cuts is to prioritize them constantly during sprint and yearly planning meetings. For example, while working on [AWS Copilot](https://github.com/aws/copilot-cli), besides allocating headcount for oncall and the "big rock" [^1] items, the team always had at least one person working on smaller usability issues or "low-hanging fruits" [^2].

![headcount allocation over time](/assets/sweating-the-small-stuff/headcount-allocation.png){: .center-image .mediumish }
<span class="center-image" style="text-align: center;"><i>Figure 1 - Sample headcount allocation over time on a small team</i></span>

These smaller issues and features can typically be shipped within a single sprint (e.g., ~2 weeks) and present a great opportunity for junior engineers to earn the team’s trust, or for a more senior engineer to gain back confidence by delivering results quickly to customers. The dedicated swimlane for improvements also creates breathing room to tackle larger usability issues (e.g., [`copilot`’s progress tracker](https://efekarakus.com/2021/02/04/how-to-solve-it-progress-tracker.html)) when deemed appropriate. I found that Colm MacCárthaigh’s [observations](https://twitter.com/colmmacc/status/1034168199187652608) on a software development engineer’s autonomy and vision durations to be a pretty useful framework for strategic planning. Aiming for a prioritized backlog of paper cuts of various sizes and small features for the next 3 months is good enough to ensure team satisfaction.

**For cross-team paper cuts**, I only have one datapoint so I can’t speak from experience confidently, but I believe that in this scenario a single individual should lead the efforts to create alignment across software development and product managers to prioritize the same set of paper cuts and small features. The responsible person starts by gathering a list of improvements _broadly_ across SDMs and PMs; then, the lead partners _narrowly_ (e.g., with a Sr. SDM) to draft a short-term plan and highlight dependencies between teams. Finally, the lead opens back up the discussion _broadly_ to PMs and SDMs seeking approval on priorities and timelines.

[^1]:<p>Larger feature work that aligns the product with the vision and should result in significant business impact.</p>

[^2]:<p>Small feature improvements that are fairly straightforward to deliver.</p>