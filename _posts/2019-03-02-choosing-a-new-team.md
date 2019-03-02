---
layout: post
title: Choosing a new team
tags: [career]
---
> Because we spend so much of our time at work, one of the most powerful leverage points for increasing our learning rate is our choice of work environment.  

[“Chapter 2.” The Effective Engineer: How to Leverage Your Efforts in Software Engineering to Make a Disproportionate and Meaningful Impact, by Edmond Lau](https://www.amazon.com/Effective-Engineer-Engineering-Disproportionate-Meaningful/dp/0996128107/ref=sr_1_sc_1?ie=UTF8&qid=1550643410&sr=8-1-spell&keywords=the+effective+engineerin)

I recently switched teams within Amazon. While searching for a good fit, I created and used a template to interview managers and engineers. I tried to compress important values that I learned over the past 3.5 years into the document. Although not every question is applicable to everyone, it provided a good starting point for a discussion. It took me over 2 months to find what I'm hoping is a good fit. If you also have the luxury of time, I'd recommend taking it slow to relieve pressure. The exercise of searching for a new team also re-iterated the importance of networking. I'm sharing my template here, hoping that it would be helpful for others. 

## Why switch teams?
There are several reasons why you might want to consider moving to a different team. The underlying theme here is about maximizing your learning. This is not an exhaustive list, it's strictly from observations from friends and myself:

* **Toxic team environment**: You've team member(s) that're clearly detrimental to you or others. Management isn't willing to create a safe work environment. If you can't get along with the people, you won't have a good time at work.  
* **Slow innovation pace**: Leadership that's indecisive on the vision of a product will result in its failure. Analysis paralysis is deadly and reversible decisions shoud be embraced by management _*_.
* **Mastery**: Realign yourself with your personal interests within computing. Over time, I realized that I enjoy the most learning about software development practices and building/operating distributed systems. 
* **Autonomy**: Be able to choose what to work on and have discussions with management to shape the product. Otherwise, you'll miss out on exciting projects.
* **People**: Surround yourself with people that will elevate you. Try to be closer to your role models. The new team that I joined works with a principal engineer, I'm hoping that will help me grow in unexpected ways.

_* As engineers we can help management get answers faster without degrading customer experience by investing in [operational excellence](https://aws.amazon.com/architecture/well-architected/#Operational_Excellence) and [feature flags](https://martinfowler.com/articles/feature-toggles.html)._

## Criteria

These are the traits that I'm looking for ideally in a team. Most of these are taken from [Edmund Lau's The Effective Engineer](https://www.amazon.com/Effective-Engineer-Engineering-Disproportionate-Meaningful/dp/0996128107/ref=sr_1_sc_1?ie=UTF8&qid=1550643410&sr=8-1-spell&keywords=the+effective+engineerin) book with slight tweaks for my interests:

* **Fast growth**: I want to be on a team that's starting their growth. Prefer new teams over established ones to have higher impact. Watch for business metrics and recruitment. The goal is to have ample opportunities for career growth. 
* **Training**: The team environment must encourage my self growth. I need to have daily time to progress myself, sign up for trainings, watch talks, read blogs/papers...
* **Openness**: I want to be in an environment where asking questions is safe and encouraged. The team must be self-reflecting. The team must be willing to look into new technologies.
* **Pace**: We must iterate quickly. Short release cycles, automated tools, tests, lightweight approval
processes, willingness to prototype to accelerate learning.
* **People**: Be surrounded with potential teachers and mentors. [Seek diversity](https://youtu.be/iLS6NXMXtLI?t=2647) in gender, country of origin, industry, career path.
* **Autonomy**: Have the freedom to choose what to work on so that I can challenge myself. Get the support needed while working on tasks.
* **Mastery**: I'm looking to really dive deep into understanding a problem space, becoming an expert and pushing the boundary.

## Questions by criteria
Before talking with teams, I broke down questions by {% include label.html content="management" color="p" %} and 
{% include label.html content="engineering" color="g" %}. 

#### Fast growth
* _Does the team have any core business metrics (e.g. revenue, active users, retention, ...) that the team uses to make
important decisions? What is the weekly or monthly growth rate of these metrics?_ {% include label.html content="management" color="p" %}
* _How quickly is the team and organization growing? How many engineers have been hired in the past year?_ {% include label.html content="management" color="p" %}
* _How quickly have the strongest team members grown into the next level? Is there an opportunity to become a senior engineer?_ {% include label.html content="management" color="p" %}
* _Will the work that I've done on my current team be accounted for my promotion? How will I know it's accounted?_ {% include label.html content="management" color="p" %}

#### Training
* _How are engineers onboarded to the team? Is there a formalized mentorship or a set way of onboarding a new engineer?_ {% include label.html content="management" color="p" %}

#### Openness
* _Are engineers "one-person teams"? Do they deliver features together or work on silo-ed projects?_ {% include label.html content="management" color="p" %} {% include label.html content="engineering" color="g" %}
* _Does the team know of each other's work? How do they know what are the priorities across and within the team?_ {% include label.html content="management" color="p" %} {% include label.html content="engineering" color="g" %}
* _Is there some form of software delivery process followed by the team? Kanban, Scrum? Does the team do retrospectives/post-mortems?_ {% include label.html content="management" color="p" %} {% include label.html content="engineering" color="g" %}
* _Does the team do any activities together? Like eating lunch?_ {% include label.html content="management" color="p" %} {% include label.html content="engineering" color="g" %}
* _Is the team atmosphere friendly? Do people respect each other? Is asking questions safe and encouranged?_ {% include label.html content="engineering" color="g" %}
* _Is the team welcoming of new technologies?_ {% include label.html content="engineering" color="g" %}

#### Pace
* _What does the team structure look like? How close are engineers to customers? How do they work with (technical) product managers? Is the approval process lightweight?_ {% include label.html content="management" color="p" %} {% include label.html content="engineering" color="g" %}
* _How frequently does the team deliver to the customer? Do we push changes to production quickly?_ {% include label.html content="management" color="p" %} {% include label.html content="engineering" color="g" %}
* _Is there some development process set in place to go from idea conception to launch? Timeboxed designs, prototypes, development?_ {% include label.html content="management" color="p" %} {% include label.html content="engineering" color="g" %}
* _How is the operational load? What percentage of time is spent on maintenance versus developing new products and features?_ {% include label.html content="management" color="p" %} {% include label.html content="engineering" color="g" %}
* _How often do projects get shut down in the middle of working on it? Is leadership indecisive?_ {% include label.html content="engineering" color="g" %}

#### People
* _How senior are the engineers on the team? Is the team diverse in terms of experience? What's the average year of experience?_ {% include label.html content="management" color="p" %}
* _How does the team share knowledge with each other? Are there folks that are actively reaching out to learn more (read, watch, share)?_ {% include label.html content="engineering" color="g" %} {% include label.html content="engineering" color="g" %}
* _Are there engineers that I can look up to? Will I be working/learning from principal engineers?_ {% include label.html content="management" color="p" %}
* _Is the team diverse? Gender, country of origin, industry, career path? Are people forming cliques or do they hang out together?_ {% include label.html content="management" color="p" %}
* _Are you learning things from your teammates? Are they smart? Is there at least one engineer that you look up to?_ {% include label.html content="engineering" color="g" %}
* _Do you have access to senior engineers/principals to bounce off ideas? Is there a culture of consultation with each other?_ {% include label.html content="engineering" color="g" %}

#### Autonomy
* _Do I have the freedom to pick which tasks to work on? How do tasks get assigned?_ {% include label.html content="management" color="p" %} {% include label.html content="engineering" color="g" %}
* _How often do individuals switch teams? projects?_ {% include label.html content="management" color="p" %}
* _Do engineers participate in discussions on product design and influence product direction?_ {% include label.html content="management" color="p" %} {% include label.html content="engineering" color="g" %}

#### Mastery
* _Get a general understanding of what the team does. What are the current biggest challenges left in the problem space? Why are they hard?_ {% include label.html content="management" color="p" %}
* _Is there an opportunity for me to become a master of a specific field? Or am I going to be more of a generalist engineer?_ {% include label.html content="management" color="p" %}
* _Do you feel like you've grown a lot over the last year? Are you learning during work hours?_ {% include label.html content="engineering" color="g" %}