---
name: dynamic-workflow-run
description: Use when executing a scoped Dynamic Workflow fan-out by explicitly spawning Codex subagents, waiting for all results, and synthesizing evidence-backed summaries.
---

# Dynamic Workflow Run

Use this skill to execute the read-heavy part of a scoped Dynamic Workflow with
Codex subagents. This is not the Claude JavaScript workflow runtime. It is a
Codex-native orchestration pattern that uses explicit subagent spawning,
waiting, review, and synthesis.

## Workflow

1. Confirm the plan, target scope, and read-only boundary.
2. Choose 2 to 5 independent worker tasks. Prefer fewer workers unless the
   target is clearly parallel.
3. Spawn one Codex subagent per worker task. Prefer the built-in `explorer`
   agent for read-heavy discovery when an agent type is available.
4. Give every subagent a bounded scope, independent question, read-only
   constraint, output contract, and evidence requirement.
5. Tell every subagent to return only a concise summary, file references,
   command evidence, risks, contradictions, and unverified areas.
6. Wait for all spawned subagents to finish before synthesizing. If one fails,
   report the failure as incomplete evidence instead of hiding it.
7. Synthesize the subagent results into a single handoff for
   `dynamic-workflow-review`.
8. Stop before write-heavy implementation unless the user explicitly approved
   that phase.

## Worker Brief Template

Each worker brief should include:

- `目的`
- `対象範囲`
- `禁止事項`
- `確認コマンド`
- `期待する成果物`
- `未検証範囲の書き方`

## Spawn Prompt Template

Use a prompt with this shape when asking Codex to run the fan-out:

```text
Spawn one Codex subagent per worker task below. Use read-only exploration.
Wait for all subagents to finish, then synthesize their findings.

Worker 1: <scope, question, evidence contract>
Worker 2: <scope, question, evidence contract>
Worker 3: <scope, question, evidence contract>
```

## Synthesis Contract

Return the final synthesis in Japanese with:

- `Subagent Summary`
- `Confirmed Findings`
- `Contradictions`
- `Missing Evidence`
- `Security Concerns`
- `Recommended Review Input`

## Safety Rules

- Do not expose secrets, `.env`, credentials, private keys, personal
  information, or confidential external data.
- Do not ask workers to modify files during read-only fan-out.
- Keep worker count small enough to control token cost and review quality.
- Treat contradictory worker findings as inputs for review, not final truth.
- If subagents cannot be spawned in the current surface, report that limitation
  and fall back to a sequential checklist without claiming parallel execution.
