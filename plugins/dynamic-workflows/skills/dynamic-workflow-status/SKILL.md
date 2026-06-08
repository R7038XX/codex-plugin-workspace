---
name: dynamic-workflow-status
description: Use when reporting Dynamic Workflow progress, evidence, completed work, remaining work, blockers, risks, and next actions in concise Japanese.
---

# Dynamic Workflow Status

Use this skill to summarize progress during or after a Dynamic Workflow.

## Workflow

1. Compare the current state with the original goal and completion criteria.
2. Report completed work with concrete evidence.
3. Report remaining work without redefining the goal.
4. Mark blockers only when progress is impossible without external input.
5. Include lint, test, build, docs, and security status when relevant.
6. End with the next 1 to 3 concrete actions.

## Output Contract

Return concise Japanese status with:

- `完了`
- `検証結果`
- `未完了`
- `リスク`
- `次アクション`

## Safety Rules

- Do not claim completion from intent or partial progress.
- Treat missing evidence as incomplete.
- Do not include secrets, `.env`, credentials, private keys, personal
  information, or confidential external data.
- Keep the original user goal intact.
