# Software design and OODA loops

This is short digression on one possible process for 'doing' design.

The first point to make is that in software, design is a *continual* activity (the word design as a verb, not a noun). You are not going to be able to sit down and completely 'design' your entire software product in a single session and then type in the code that implements the design.

Instead, design is **iterative** - you are refining the same software product (which could be anything from a single class to an entire system) multiple times. Start with something simple and then improve on it through analysis and problem-solving to produce a (hopefully) better version.

One way of tackling an iteration is to follow the **OODA Loop**. Ironically OODA doesn't mean "Object-Oriented Design Analysis": OODA stands for **Observation**, **Orientation**, **Decision**, **Action** (or if you prefer **Observe**, **Orientate**, **Decide**, **Act**).

## 1. Observation (Observe)
- Look at your classes and the types they are aggregating or associating with. What does their public API look like? What kind of responsibilities do they have? What options for extensibility to they need?
- If you are working with code written by others, or using library code you will need to make the same observations as you did for your code.
- Modelling code in UML, even if just some sketches on paper is an excellent way to observe the structure of your and other's code.

The observation stage ensures you have an understanding of the code (you might not have seen it before), and how it interacts with its environment, which is likely to be other classes and application data.

## 2. Orientation (Orientate)
This is the thinking part where you **analyse** the problem again.

- Apply your existing learning and knowledge such as your knowledge of coding standards, design patterns and principles.
- Identify weaknesses in the design and opportunities to make it cleaner, more extensible, more testable and to tighten up the responsibilities of each class.
- Be critical about the code structure, functionality, and relationships.
- Apply any new knowledge from the previous revisions or new information gained from product specifications or observation.

Bring together all that you have learnt in this phase to propose a new structure for the software. The process of bringing together all this information is **Synthesis**.

## 3. Decision (Decide)
Your analysis and synthesis may generate multiple options, so you need to decide which changes and additions you want to implement in this iteration.

## 4. Action (Act)
In software engineering this coding the set of changes and additions you agreed with yourself in the Decision step.

## Repeat

Now the cycle repeats (this is the loop in OODA Loop) - Observe if your changes have made improvements you hoped for and look again at all the things you looked at in your initial observation in the light of the new software structure and behavior. Repeat the Orientation, Decision and Action steps.

## Summary

With practice, this decision-making loop should become second nature. Keeping the **OODA** cycle in mind gives you a sequence of specific steps to follow. The study of good coding practice, design patterns and refactoring will help inform your observation and orientation.

As we are working with software, we have technology to help us with this looping.

- Today's machines and compilers are so quick that the time to compile and run another version is short which makes it low cost to try out a new version.
- Use Git branching to isolate your change from the main branch. What this means in practice is that we can create a branch, make a lot of changes and if we don't like the result (we didn't get the improvements we wanted) we can revert back to the previous (unchanged) branch. We can use Git to ensure a completely safe undo of our changes. Conversely if we like our changes we can keep them by merging them back into the original branch.


## History
The OODA loop is a general model of the continuous nature of decision-making in dynamic environments and is credited to US Military Strategist John Boyd.
