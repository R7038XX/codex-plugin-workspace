---
name: dynamic-workflow-orchestrate
description: Use when a task needs an end-to-end Codex-native Dynamic Workflow that scopes work, explicitly spawns subagents, waits for results, reviews findings, and synthesizes a final answer.
---

# Dynamic Workflow Orchestrate

Use this skill when the user wants Claude Code dynamic workflows-like behavior
inside Codex without using the Claude JavaScript workflow runtime. This skill
orchestrates the full workflow with Codex's explicit subagent workflow model.

## Workflow

1. Scope the request and confirm whether the first phase is read-only.
2. Split the work into 2 to 5 independent worker tasks.
3. Spawn one Codex subagent per worker task. Prefer `explorer` for read-heavy
   investigation, `worker` for explicitly approved implementation, and
   `default` when no specialized agent fits.
4. Give each subagent a bounded brief with scope, question, constraints,
   expected evidence, output contract, and prohibited actions.
5. Wait for every spawned subagent to finish. If any subagent fails, timeouts,
   or cannot run, record the missing evidence explicitly.
6. Merge the subagent summaries and run an adversarial review pass:
   duplicate findings, contradictions, risk ranking, and missing tests.
7. Synthesize one Japanese final answer with evidence, risks, incomplete work,
   and next actions.
8. Stop before write-heavy work unless the user explicitly approved it.

## Worker Brief Contract

Each spawned subagent must receive:

- `目的`
- `対象範囲`
- `使用する agent`
- `禁止事項`
- `確認コマンド`
- `期待する成果物`
- `未検証範囲`

## Final Output Contract

Return:

- `Workflow Summary`
- `Subagent Results`
- `Confirmed Findings`
- `Contradictions`
- `Missing Evidence`
- `Security Concerns`
- `Recommended Next Actions`

## Fallback

If Codex cannot spawn subagents in the active surface, say so plainly and run a
sequential checklist instead. Do not claim parallel execution when no subagents
were spawned.

## Safety Rules

- Do not expose secrets, `.env`, credentials, tokens, private keys, personal
  information, or confidential external data.
- Default to read-only subagents.
- Keep worker count small enough to control token cost and review quality.
- Treat missing evidence as incomplete, not as success.
- Do not start write-heavy work without explicit user approval.
