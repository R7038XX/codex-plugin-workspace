---
name: dynamic-workflow-review
description: Use when multiple Dynamic Workflow findings need adversarial review, duplicate merging, risk ranking, evidence checks, and release-readiness judgment.
---

# Dynamic Workflow Review

Use this skill to review worker outputs or broad investigation notes before
implementation or release decisions.

## Workflow

1. Normalize all findings into a common format.
2. Merge duplicates and preserve the strongest evidence.
3. Rank findings by severity, likelihood, blast radius, and reversibility.
4. Challenge each important finding with an adversarial question.
5. Separate proven findings from plausible, contradicted, and unverified items.
6. Identify missing tests, documentation gaps, and security concerns.
7. Produce a short synthesis and recommended next action.

## Finding Format

Use this structure in Japanese:

- `ID`
- `Severity`
- `Finding`
- `Evidence`
- `Impact`
- `Counterargument`
- `Status`
- `Recommended Action`

## Safety Rules

- Do not treat a narrow check as proof of broad completion.
- Do not hide uncertainty. Mark weak evidence as weak.
- Do not include secrets, `.env`, credentials, private keys, personal
  information, or sensitive data in evidence excerpts.
- Prefer file references and command summaries over long pasted output.
