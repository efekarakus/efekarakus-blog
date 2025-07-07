---
layout: post
title: "Experimentation over capabilities"
tags: [llm]
---

{: display: block;"}
![Value via features](/assets/experimentation-over-capabilities/grow-value-via-features.png){: style="float: left; margin: 0px 15px 0px 0px;" width="250"} In traditional software engineering, we create customer value by working on small, focused features delivered frequently. When building products where generative AI is a key component, I've noticed organizations adopting the term "capability" with similar intentions.

A capability encompasses both features (functionality with clear specifications, designs, and implementation) and evaluations that must pass reliably (test scenarios for LLM-based applications). 

The challenge is that it’s inherently difficult for a [small team](https://aws.amazon.com/executive-insights/content/amazon-two-pizza-team/) to guarantee eval results within a sprint timeline. LLM-based systems have too many unknowns that need to be resolved via an iterative process also known as [context engineering](https://simonwillison.net/2025/Jun/27/context-engineering/). Teams need domain expertise and good judgment to encode their wisdom into their LLM systems, then rigorously measure and tune based on test scenarios to [improve what goes into the context](https://www.dbreunig.com/2025/06/26/how-to-fix-your-context.html).

When teams face pressure to pass specific scenarios by sprint's end, they often build subpar products. Instead of creating flexible implementations that generalize well, they over-tune system prompts or artificially constrain tool specifications to guarantee successful outcomes on a narrow set of tests.

{: display: block;"}
![Value via exp](/assets/experimentation-over-capabilities/grow-value-via-experiments.png){: style="float: left; margin: 0px 15px 0px 0px;" width="250"} Rather than expecting guaranteed capabilities as sprint outputs, teams building LLM-based products should focus on (i) defining experiments and (ii) growing their evaluation test suites.

Before each sprint, teams should consult with domain experts to:

1. **Propose an experimental approach** for addressing the evals (divide and conquering a multi-agent architecture, agent roles, tool specifications)  
2. **Propose additional realistic eval scenarios** that test new potential failure modes

At sprint's end, teams report eval [pass rates](https://www.philschmid.de/agents-pass-at-k-pass-power-k) (pass@1, pass@k, and passk) and provide an [error analysis](https://hamel.dev/notes/llm/officehours/erroranalysis.html) report explaining where the system falls short. This analysis then informs the next set of experiments to address those gaps.

