---
layout: post
title: "Harness engineering rules of thumb"
tagline: "A few tenets I keep in mind while building agent harnesses that ride the model improvement curve."
tags: [llm]
---

This blog post is for folks working on harness engineering. My intention is to write down the tenets that I keep in my head: tenets that position us to ride the curve (as we upgrade a model, our agent becomes better) rather than constantly babysitting and tweaking our agents.

### **1. Don't bring your intelligence as instructions**

This is the most common feedback I give in code reviews. Frontier models like Claude Opus are smarter than you and I. The following guidance from Anthropic on authoring `CLAUDE.md` files and skills applies equally to the system prompt:

> *Keep it concise. For each line, ask: "Would removing this cause Claude to make mistakes?" If not, cut it. Bloated CLAUDE.md files cause Claude to ignore your actual instructions!*
> [Write an effective CLAUDE.md](https://code.claude.com/docs/en/best-practices#write-an-effective-claude-md)

> **Default assumption:** Claude is already very smart.
> *Only add context Claude doesn't already have. Challenge each piece of information:*
> *- "Does Claude really need this explanation?"*
> *- "Can I assume Claude knows this?"*
> *- "Does this paragraph justify its token cost?"*
> [Agent Skills Best Practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices#concise-is-key)

<span class="text-highlight">The most common fallacy I see is adding new tools to an agent's harness and then asking a coding agent to write instructions on how to use those tools, or being overly prescriptive because one thinks they know better than the LLM.</span> In both cases, you're wasting tokens on guidance the model doesn't need. Don't regurgitate and don't over-specify: unless you can demonstrate that the LLM can't achieve its goal effectively without the instructions, leave them out.

Evaluate whether the agent *without any instructions* can effectively accomplish the task. If so, you're done.

> *Perfection is achieved, not when there is nothing more to add, but when there is nothing left to take away.*

The north star is a [system prompt like the Pi coding agent's](https://youtu.be/RjfbvDXpFls?si=A-eW8jRozH_Os-lR&t=379). For every change to the system prompt or a tool spec, aim to:

- Remove more instruction lines than you add.
- Merge your instructions with an existing section to establish a more generic pattern.

### **2. Instruct only the quirks**

Only add guidance when you can demonstrate that the LLM keeps making the same mistake over and over without it. Even then, add the most minimal and generic instructions to course-correct.

For example, Claude repeatedly uses `/i` as a syntax while querying CloudWatch Logs Insights. Telling the agent explicitly which syntaxes are not supported fits into a "tool quirk" bucket. Instructions and examples for quirks like these are justified.

### **3. Expand capabilities, compress context**

Our primary work is to unlock the LLM's power by expanding its capabilities and managing its context window (no [poisons, distractions, confusions, clashes](https://www.dbreunig.com/2025/06/22/how-contexts-fail-and-how-to-fix-them.html)).

Add new tools that unlock new use cases for your agent. However, be careful about how many tools you add, your agent's [performance degrades](https://www.dbreunig.com/2025/06/26/how-to-fix-your-context.html#tool-loadout) the more you increase its cognitive load. Skills are a great way of expanding capability while keeping your system prompt lean: provide new capabilities as skills that the agent loads on demand.

**[Progressive disclosure](https://agentskills.io/specification#progressive-disclosure).** Structure your tools so that the LLM can pull data progressively into its context window. For the DevOps Agent, if a tool result exceeds ~10k tokens, the agent returns a preview (~1k tokens) and the LLM can decide to apply additional filters, use a `distill` tool to have a fast LLM extract only the signal, or `read` and `grep` from the large result via a file system path. All of these reduce distracting tokens in the context window. Think hierarchically: tools that drill down on the necessary data progressively.

**Lean into training and tuning.** Create flexible tool interfaces that leverage what the LLM was trained with. For example, rather than having separate individual tools to interact with the Kubernetes API, if you can just use `kubectl` directly that's ideal. Otherwise, a tool that closely matches the `kubectl` interface will be closest to what the LLM is trained with *and* more flexible by reducing the number of tools in the context window. If you see a pair of tools always used together, consider merging them.

The classic advice from [John Ousterhout](https://www.amazon.com/Philosophy-Software-Design-John-Ousterhout/dp/1732102201) on "design it twice" applies to tool design. Rather than going with the first tool interface that comes to mind, force yourself to write at least one alternative and ask: "Does one have a simpler interface?", "Is one more general-purpose?", "Does one enable a more efficient implementation?"

### **4. Guard the cache**

Be vigilant about prompt caching. Adding tools progressively to the context window will invalidate your cache. Dynamic content on each turn that changes your system prompt (e.g., a timestamp) will invalidate your cache. Aim for a strictly append-only context window.
