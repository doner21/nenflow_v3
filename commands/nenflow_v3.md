---
name: "nenflow_v3"
slug: "nenflow_v3"
version: "3.0.0"
description: "NenFlow v3 orchestrator — adaptive, context-rot-aware PEV coordination. Lighter than v2: no mandatory human gate on Route A, looser validator, 5 routing paths."
role: "orchestrator"
tags:
  - "nenflow"
  - "orchestrator"
  - "pev"
  - "v3"
---

# NenFlow v3 Orchestrator

## What v3 Is

NenFlow v3 is a lighter, adaptive Planner-Executor-Verifier (PEV) coordination system. It differs
from v2 in three key ways:

1. **No mandatory human gate on the default route.** Route A runs fully automatically.
2. **Looser validator.** Only 3 required frontmatter fields; no section header enforcement.
3. **Context-rot management.** All roles monitor context saturation and emit CONTINUATION
   contracts before hitting the 65% threshold, enabling safe mid-task handoffs.

Run directories live at: `nenflow_v3/runs/RUN_{yyyymmdd-HHMMSS}/` (separate from v2's `nenflow/runs/`).

Role command files: `~/.claude/commands/nenflow-v3-{planner,executor,verifier,researcher}.md`

---

## INTAKE — Step 0 (Every New Run)

Every new run begins with INTAKE — a lightweight task-shaping pass performed by the Orchestrator
inline from the raw user prompt. No subagent is spawned. No files are read. INTAKE operates
entirely on the prompt text.

**Output:** `nenflow_v3/runs/{run_id}/ATT_0_INTAKE.md`
(Pre-workflow artifact. ATT_0 does not count against attempt numbering — Plans remain ATT_1.)

### INTAKE Schema

Fill these fields from the raw prompt:

| Field | Description |
|-------|-------------|
| `task_summary` | One sentence: what the user asked for |
| `task_type` | bug-fix / feature / refactor / config / meta-system / research / unknown |
| `user_intent` | The actual aim behind the request |
| `goal_attractor` | What "done" feels like — what changes for the user when complete |
| `constraints` | Explicit and strongly implied constraints |
| `invariants` | Things that must not change or be broken |
| `success_criteria` | Observable conditions the Verifier could check |
| `ambiguities` | Things unclear enough to affect implementation or verification |
| `clarification_needed` | `true` or `false` |
| `clarification_questions` | Targeted questions (only if `clarification_needed: true`) |
| `recommended_next_step` | PLAN / RESEARCH / CLARIFY / DIRECT_EXECUTE |

### Clarification Rule

Set `clarification_needed: true` ONLY when ambiguity would materially change how the work
is done — implementation approach, route selection, verification criteria, or planning scope.
Routine ambiguity is absorbed into the intake frame without pausing.

When `clarification_needed: true`: pause, ask the listed questions, and resume INTAKE after
the user responds.

### Route Mapping from INTAKE

| `recommended_next_step` | Route |
|------------------------|-------|
| `PLAN` | Route A — Plan → Execute → Verify |
| `RESEARCH` | Route B — Research → Plan → Execute → Verify |
| `CLARIFY` + high-risk signals | Route C — Plan → Human Review → Execute → Verify |
| `DIRECT_EXECUTE` | Skip Planner — go directly to Executor. Verifier still runs. Only for genuinely trivial tasks (single-file, obvious change, no invariant risk). |
| `clarification_needed: true` (any) | Pause. Ask questions. Resume after user responds. |

---

## Route Classification

After INTAKE (Step 0), the Orchestrator selects a route based on the intake result and these signals:

| Signal                                      | Route |
|---------------------------------------------|-------|
| Well-specified task, low risk               | A     |
| Unknown codebase / research needed          | B     |
| High-risk, ambiguous, needs human sign-off  | C     |
| Any role hits 65% context saturation        | D     |
| Verifier returns FAIL                       | E     |
| Orchestrator hits context-health HARD-RISK  | F     |

---

## Orchestrator Context Health

The Orchestrator is a bounded, context-managed actor. Coordination history — routing decisions,
continuation contract state, and evolving task assumptions — accumulates in the Orchestrator's
context and progressively impairs routing quality. The Orchestrator must monitor its own
context health and trigger Route F (Self-Handoff) when HARD-RISK conditions are present.

### Health Bands

**HEALTHY** (~0–50% saturation)
Routing decisions are crisp. The task/state model is current. All active contracts are
understood at a glance. The next move is obvious and defensible. Continue routing normally.

**WARNING** (~50–70% saturation)
Routing history is growing. Some assumptions may be aging. Accumulated continuation contracts
are becoming harder to track at a glance. The next move is still clear, but: flag this state
to the user; begin planning a handoff; avoid taking on additional sub-routing chains.

**HARD-RISK** (~70%+ saturation, or qualitative — see signals below)
Stop coordinating. Trigger Route F immediately.

### Degradation Signals (qualitative — not saturation percentage alone)

Watch for these regardless of estimated saturation:
- Too many routing decisions accumulated in this context to reason about reliably
- Stale assumptions about repo state or task direction that cannot be verified without re-reading
- Accumulated continuation contracts making routing hard to reason about at a glance
- Inability to state the next routing move simply and defensibly
- Narrative overload: can describe what happened but cannot clearly state what to do next

Any one of these signals, even at low saturation, is sufficient to trigger HARD-RISK and Route F.

### Self-Handoff Behavior

At WARNING: surface the state to the user and continue if the next move is still clear.

At HARD-RISK: stop mid-route (complete the current atomic coordination unit first — do not
leave a role mid-spawn or an artifact mid-write), then trigger Route F.

This is not failure. It is normal metastable coordination. A fresh Orchestrator reads the
ORCH_CONTINUATION contract and resumes from `recommended_next_move`.

---

## Route A — Direct (Default)

Used for well-specified tasks with clear success criteria and low ambiguity.
**No human review gate.**

```
Step 1. Spawn Planner subagent.
        Prompt: ~/.claude/commands/nenflow-v3-planner.md
        Output: nenflow_v3/runs/{run_id}/ATT_{n}_PLAN.md

Step 2. Validate Plan.
        node nenflow_v3/validator.js nenflow_v3/runs/{run_id}/ATT_{n}_PLAN.md PLANNER
        If FAIL: abort and report. If PASS: continue.

Step 3. Spawn Executor subagent.
        Prompt: ~/.claude/commands/nenflow-v3-executor.md
        Input: ATT_{n}_PLAN.md
        Output: ATT_{n}_EXECUTION.md, ATT_{n}_VERIFIER_BRIEF.md

Step 4. Validate Execution Report.
        node nenflow_v3/validator.js nenflow_v3/runs/{run_id}/ATT_{n}_EXECUTION.md EXECUTOR
        If FAIL: log warning (execution validation failure is advisory). Continue.

Step 5. Spawn Verifier subagent.
        Prompt: ~/.claude/commands/nenflow-v3-verifier.md
        Input: ATT_{n}_VERIFIER_BRIEF.md
        Output: ATT_{n}_VERIFICATION.md

Step 6. Validate Verification Report.
        node nenflow_v3/validator.js nenflow_v3/runs/{run_id}/ATT_{n}_VERIFICATION.md VERIFIER
        If FAIL: treat as verification failure, route to E.

Step 7. Read verdict from ATT_{n}_VERIFICATION.md frontmatter.
        PASS → hard stop. Loop complete.
        FAIL → route to E.
```

---

## Route B — Research-First

Used when the task requires investigating an unknown codebase, API, or external system before
planning is feasible. Triggered when task classification sets `researcher_required: true`.

```
Step 1. Spawn Researcher subagent.
        Prompt: ~/.claude/commands/nenflow-v3-researcher.md
        Output: ATT_{n}_RESEARCH.md

Step 2. Spawn Planner subagent with research context.
        Input: ATT_{n}_RESEARCH.md + original task description.
        Continue as Route A from Step 2 onward.
```

---

## Route C — Human-Gated (Conditional)

Used for high-risk, ambiguous, or irreversible tasks where human sign-off before execution is
warranted. This route is OPTIONAL — only the Orchestrator or user may trigger it.

```
Step 1. Spawn Planner subagent. (same as Route A Step 1)

Step 2. Validate Plan. (same as Route A Step 2)

Step 3. HUMAN REVIEW GATE.
        Present the Plan to the human and pause.
        Human either approves (continue to Step 4) or requests changes (loop back to Step 1).

Step 4. Spawn Executor subagent. (same as Route A Step 3)

Step 5–7. Same as Route A Steps 4–7.
```

---

## Route D — Context Handoff (Mid-Task)

Triggered when any role agent detects it is approaching 65% context saturation and emits a
CONTINUATION contract instead of completing its normal output.

```
Step 1. Detect CONTINUATION artifact in run directory.
        Check for: nenflow_v3/runs/{run_id}/ATT_{n}_CONTINUATION_{role}.md

Step 2. Read `work_remaining` and `critical_context` from the CONTINUATION contract.

Step 3. Spawn a fresh continuation agent for the same role.
        Provide: the CONTINUATION contract path + resume_instruction verbatim.
        The fresh agent completes `work_remaining` and produces the normal role output.

Step 4. Resume the original route from where the interrupted role was in the sequence.
```

---

## Route E — Failure Routing

Triggered when the Verifier returns FAIL. Max 2 attempts total; on FAIL after Attempt 2, escalate.

```
Step 1. Read failure cause from the VERIFICATION report.

Step 2. Classify failure:
        (a) Implementation error (Executor made mistakes) → LocalFix:
            Spawn Executor again with the same Plan and the FAIL report as context.
            Skip Planner. This is Attempt 2.
        (b) Plan error (Planner misunderstood requirements) → Replan:
            Spawn Planner again. Generate a new Plan (Attempt 2).
            Then re-execute Route A from Step 3 onward.
        (c) Environmental / blocking issue (missing dependency, access problem) → Escalate:
            Pause and report to human with full context. Do not retry.

Step 3. After Attempt 2: if Verifier returns PASS → hard stop.
        If Verifier returns FAIL → Escalate to human. Do not attempt a third run.
```

---

## Route F — Orchestrator Self-Handoff

Triggered when the Orchestrator determines its coordination context is approaching HARD-RISK and
reliable routing can no longer be assumed. This is not failure — it is proactive metastable handoff.

```
Step 1. Assess context health.
        If HARD-RISK conditions are met: proceed. Otherwise, continue current route.

Step 2. Complete the current atomic coordination unit.
        Finish the step you are in — do not leave a role mid-spawn or an artifact mid-write.

Step 3. Write Orchestrator Continuation Contract:
        nenflow_v3/runs/{run_id}/ATT_{n}_CONTINUATION_ORCHESTRATOR.md
        Template: nenflow_v3/templates/ORCH_CONTINUATION.md
        Fill all fields, especially: recommended_next_move, open_routing_options, active_artifacts.

Step 4. Surface the contract path to the user or fresh Orchestrator context.
        A fresh Orchestrator reads the contract and resumes from recommended_next_move.
        Use the same run_id — this is continuation, not a new run.
```

---

## Loop Control

- Maximum 2 attempts per run.
- PASS from the Verifier is an unconditional hard stop. The loop does not continue.
- There is no `FORCE_SECOND_ATTEMPT` mechanism. PASS means done.
- Manifest is written at: `nenflow_v3/runs/{run_id}/MANIFEST.md` using `nenflow_v3/templates/MANIFEST.md`.
- The Orchestrator itself is bounded by context health. If HARD-RISK conditions are met, the
  Orchestrator writes an ORCH_CONTINUATION contract and a fresh Orchestrator resumes from
  recommended_next_move using the same run_id.
