---
name: deslopify
description: Audit and refine an existing product to remove AI-like copy, visual clutter, redundant information, awkward interactions, inconsistent conventions, and needless implementation complexity. Use for cleanup, polish, simplification, UX refinement, copy editing, UI consistency, or “make this feel intentional” requests across apps, websites, documents, and other user-facing products.
---

# Deslopify

Make the product feel deliberate, clear, and human without erasing its identity or rebuilding it unnecessarily.

## Work from evidence

Inspect the current product, source, and supplied references before editing. Run or render the product when practical. Trace confusing UI back to its data and behavior; do not treat every problem as cosmetic.

Identify the highest-impact friction first:

- repeated or low-value information
- vague, inflated, robotic, or implementation-leaking copy
- weak hierarchy and excessive cards, badges, callouts, borders, or controls
- inconsistent names, formatting, spacing, component behavior, or navigation
- hidden, surprising, inaccessible, or unnecessarily multi-step interactions
- overflow, truncation, empty states, invalid states, and poor responsive behavior
- duplicated logic, brittle validation, dead code, and abstractions that add no value

## Simplify deliberately

Preserve useful features and established visual language. Prefer subtraction, consolidation, and clearer defaults over a wholesale redesign.

Make every element earn its space. Remove content that neither informs a decision, explains state, nor enables an action. Show information once, where it is most useful. Use progressive disclosure for secondary detail.

Rewrite copy in plain language:

- use short, specific labels and sentences
- lead with the information or action the user needs
- remove throat-clearing, marketing filler, fake helpfulness, and obvious confirmations
- avoid exposing prompts, schemas, internal mechanisms, or developer terminology
- keep terminology, capitalization, units, currency, dates, and app names consistent
- retain necessary warnings, constraints, and recovery guidance

Refine interaction and layout:

- make primary actions obvious and secondary actions quiet
- use familiar controls with clear affordances and visible feedback
- reduce competing emphasis; do not make every section a card or every value a badge
- disable impossible actions and explain why only when the reason is not evident
- preserve selection, keyboard use, focus, readable contrast, and sensible hit targets
- handle loading, empty, error, long-content, and narrow-screen states intentionally

Keep implementation simple. Reuse an existing good pattern before adding a new one. Remove obsolete code and dependencies created by the cleanup. Fix root causes and contracts instead of masking symptoms with UI text or defensive layers.

## Verify the experience

Exercise the real user flows after editing, not just the happy-path render. Check navigation, forms, destructive actions, feedback, persistence, accessibility basics, overflow, and runtime errors. Follow the project’s own validation and tool instructions.

Revisit anything that became prettier but less clear, more generic, or less capable. Finish when the product communicates what matters, supports its tasks with minimal friction, and contains no obvious residue from the cleanup.
