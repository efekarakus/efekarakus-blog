---
layout: post
title: 'Sweating the small stuff'
tags: [planning]
---

At Amazon, we refer to any usability frictions or, more broadly, small product issues as [_paper cuts_](https://youtu.be/DcWqzZ3I2cY?feature=shared&t=5893). A few paper cuts aren't particularly damaging, but a thousand (paper) cuts cause significant customer pain. Fixing paper cuts and iterating on existing features is not only important to create experiences that customers are enthusiastic about, but at a personal level, it elevates our work to something we’re proud of.

**For single independent teams**, I found the most effective mechanism to tackle paper cuts is to prioritize them constantly during sprint and yearly planning meetings. For example, while working on [AWS Copilot](https://github.com/aws/copilot-cli), besides allocating headcount for oncall and the "big rock" [^1] items, the team always had at least one person working on smaller usability issues or "low-hanging fruits" [^2].

![headcount allocation over time](/assets/sweating-the-small-stuff/headcount-allocation.png){: .center-image .mediumish }
<span class="center-image" style="text-align: center;"><i>Figure 1 - Sample headcount allocation over time on a small team</i></span>

These smaller issues and features can typically be shipped within a single sprint (e.g., ~2 weeks) and present a great opportunity for junior engineers to earn the team’s trust, or for a more senior engineer to gain back confidence by delivering results quickly to customers. The dedicated swimlane for improvements also creates breathing room to tackle larger usability issues (e.g., [`copilot`’s progress tracker](https://efekarakus.com/2021/02/04/how-to-solve-it-progress-tracker.html)) when deemed appropriate. I found that Colm MacCárthaigh’s [observations](https://twitter.com/colmmacc/status/1034168199187652608) on a software development engineer’s autonomy and vision durations to be a pretty useful framework for strategic planning. Aiming for a prioritized backlog of paper cuts of various sizes and small features for the next 3 months is good enough to ensure team satisfaction.

**For cross-team paper cuts**, I only have one datapoint so I can’t speak from experience confidently, but I believe that in this scenario a single individual should lead the efforts to create alignment across software development and product managers to prioritize the same set of paper cuts and small features. The responsible person starts by gathering a list of improvements _broadly_ across SDMs and PMs; then, the lead partners _narrowly_ (e.g., with a Sr. SDM) to draft a short-term plan and highlight dependencies between teams. Finally, the lead opens back up the discussion _broadly_ to PMs and SDMs seeking approval on priorities and timelines.

[^1]:<p>Larger feature work that aligns the product with the vision and should result in significant business impact.</p>

[^2]:<p>Small feature improvements that are fairly straightforward to deliver.</p>