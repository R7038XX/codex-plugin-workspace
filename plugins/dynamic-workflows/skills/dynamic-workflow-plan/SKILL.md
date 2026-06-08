---
name: dynamic-workflow-plan
description: Use when a large Codex task needs Dynamic Workflow scoping before execution, including phases, read-only worker briefs, evidence requirements, risks, and acceptance criteria.
---

# Dynamic Workflow Plan

Use this skill to convert a broad or high-risk request into a structured
Dynamic Workflow plan before execution.

## Workflow

1. Restate the user goal in Japanese and identify the target scope.
2. Separate read-only discovery from any write phase.
3. Split the work into 2 to 5 worker tasks only when parallel work is useful.
4. Define each worker task with target files, questions, constraints, and
   expected evidence.
5. Define verification gates for lint, test, build, security, and documentation
   when relevant to the user goal.
6. List risks, missing context, and assumptions explicitly.

## Output Contract

Return a concise Japanese plan with these sections:

- `目的`
- `対象範囲`
- `Phase`
- `Worker Tasks`
- `検証`
- `リスクと未確認事項`
- `次アクション`

## Safety Rules

- Default to read-only discovery.
- Do not request secrets, `.env`, credentials, private keys, personal
  information, or confidential external data.
- Do not mix a write phase into the same step unless the user explicitly
  approved implementation work.
- Treat missing evidence as incomplete.
