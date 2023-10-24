---
layout: post
title: 'Persuasion through collaboration'
tags: [career]
---

The goal of this blog post is to enumerate techniques, adapted from Ward Farnsworth’s [The Socratic Method [1]](https://www.amazon.com/Socratic-Method-Practitioners-Handbook/dp/1567926851) and Adam Grant’s [Think Again [2]](https://www.amazon.com/Think-Again-Power-Knowing-What/dp/1984878107), for effective feedback while reviewing technical writings such as a [RFCs](https://www.ietf.org/standards/rfcs/) or [PR-FAQs](https://youtu.be/aFdpBqmDpzM?feature=shared&t=570). By effective, I mean leading the author towards a better technical direction by moving the author’s mind without being adversarial about it. 

> Rethinking depends on a different kind of network: a challenge network, a group of people we **trust** to point out our blind spots and help us overcome our weaknesses. [[2]](https://www.amazon.com/Think-Again-Power-Knowing-What/dp/1984878107)

Persuasion must be a collaborative enterprise rather than adversarial if both parties, author and reviewer, share the common goal of arriving at the best possible technical decision. 

## 1. Recount the author’s point of view
> If you want to persuade people, contradicting them doesn’t usually help. They dig in harder. You’re better off standing **next** to them rather than opposite them, so to speak. You position yourself as a partner looking for the same answers that they are. [[1]](https://www.amazon.com/Socratic-Method-Practitioners-Handbook/dp/1567926851)

Before criticizing the document under review, first the reviewer must show that they see the author’s idea in full at its best. Trust is established by showing that the reviewer “gets” the author’s point of view. You must set aside your own beliefs for a little while, and restate in your own words the strongest arguments the author is trying to make. The Socratic method is to go above and beyond and help your partner discover what they’re trying to say and elaborate it - and then you can start taking their main points apart and route them towards a different solution.

**Example 1.1.** “Let me know if I’m understanding your proposal correctly, you recommend hosting this new reporting functionality with a serverless event-driven compute service rather than a static containerized service primarily because you expect a sparse request pattern with low peaks and hence would save cost by not paying for idle time. Is that right?” 

**Example 1.2.** “Let me try to recap your proposal to make sure we’re on the same page, we prefer distributing this functionality as a software library part of our existing monolith rather than a separate microservice because it’s the quickest option for us to deliver value to our customers. Am I understanding it correctly that time-to-market is the main criteria for this architecture decision?”

## 2. Find common ground
> We won’t have much luck changing other people’s minds if we refuse to change ours. We can demonstrate openness by acknowledging where we agree with our critics and even what we’ve learned from them. Then, when we ask what views they might be willing to revise, we’re not hypocrites. [[2]](https://www.amazon.com/Think-Again-Power-Knowing-What/dp/1984878107)

Clarifying the main propositions and agreeing on valid points from the author changes the tone of the conversation and creates a safe environment for the author to change their mind. Furthermore, stating agreements signals crucial progress to the author as they won’t have to alter parts of the document with consensus and can focus on improving their shakier premises. As the reviewer, you can even help solidify the common ground by bringing precision to the discussion.

**Example 2.1.** “I agree with you that delivering functionality as fast as possible with a software library is really appealing, especially since as a new team we haven’t yet shipped a feature. Do you think that your recommendation would be even stronger if we quantify the time-to-market? How long would it take to write the feature as a library compared to moving to a server? If the delta is large, I can commit with confidence to the recommended solution.”

## 3. Lead through questions
> The Socratic method doesn’t replace your current opinions with better ones. It changes your relationship to your opinions. It replaces the love of holding them with the love of testing them. [[1]](https://www.amazon.com/Socratic-Method-Practitioners-Handbook/dp/1567926851)

Real persuasion isn’t done by forcing the author into submission, or writing embarrassing comments on the document. Instead, our task as reviewers is to have the author see things our way. In order to create an environment of cooperation, we have to change our way of delivering feedback from “X isn’t valid because of Y” to a series of little questions that builds agreement along the way until the reviewer highlights inconsistencies, exposes complexity, or gaps in the thinking of the author. 

**Example 3.1.** “Do you agree that the static service alternative would only need 2 containers to be running concurrently at all times?” (Yes.) “Then, the expected cost for the containerized option seems to be around $32/month, is that right?” (Yes.) “Then, do you think that cost is an important factor in the decision of the architecture? Can we eliminate it?”

The example above is a bit roundabout and can be short circuited if the participants trust each other. But in general, the Socratic approach forces you to move in lockstep with the author until the author arrives at an impasse that needs more thinking [^1]. Compared to a direct attack on the idea, the approach of leading through questions makes the person undergoing a review want to continue working with you.

## 4. Explicitly state “document” feedback
Finally, the last piece of advice that was given to me by one of my mentors was around _separating document feedback from idea feedback_. As a reviewer, you can suggest a different document style to help the author present their ideas more effectively but it’s important to highlight that this is not a criticism of the idea but rather of the presentation. 

**Example 4.1.** “I think all the important ideas are there in this document, but I found the decision matrix too overwhelming to digest as there were too many options to evaluate. This is a document feedback, consider structuring the document as a series of smaller decision matrices so that the cognitive load on the reader is reduced per decision.”

## Key takeaways
In summary, the key aspects of giving effective feedback are: 1/ summarize your understanding of the key points of the author to ensure you’re not misrepresenting anything and build trust, 2/ create a common ground by listing points that you agree on, 3/ ask genuine questions to test the claims, and 4/ separate style from idea feedback.

[^1]: <p>This blog post is about the <b><i>method</i></b> of giving feedback and we don't touch into practical types of feedback that helps the technical document. In this little bubble, I'm enumerating few sample ideas.</p> <p>1. As a reviewer, we can question the <b><i>validity</i></b> of the claim; sometimes the author might not be evaluating an option fairly or the aspect might not be described accurately due to a gap in the analysis.</p><p>2. We can question the <b><i>priority</i></b> of the claim; the author might be valuing a particular criterion higher than it deserves.</p><p>3. When multiple parties are going to review a document, the reviewer can ask the author to <b><i>change their perspective</i></b> and consider the proposal from the point of view of a different group.</p><p>4. As the reviewer, you can test for <a href="https://fs.blog/second-order-thinking/"><b><i>second order thinking</i></b></a>. You can assume the claim is true and ask about where it would lead in the long term.</p><p>5. Finally, you can <b><i>push for alternatives</i></b> not presented in the document; it’s quite possible that the author missed out on a different solution and we can help them to think of additional options that can meet the criteria.</p>