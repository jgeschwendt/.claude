# Prompt Corpus Evaluation

## Summary

- Total prompts scored: **90**
- Average score: **6.29 / 18**
- Prompts flagged (score < 8 or red flags): **80**
- Prompts with no red flags: **58**

## Top 10 exemplars

| Rank | Score | Kind | Path | Preview |
|---:|---:|:---|:---|:---|
| 1 | 12/18 | tool | `tools/BashTool/prompt.ts:81-160` | # Committing changes with git |
| 2 | 12/18 | tool | `tools/PowerShellTool/prompt.ts:78-144` | Executes a given PowerShell command with optional timeout. Working directory persists between commands; shell… |
| 3 | 10/18 | tool | `tools/TodoWriteTool/prompt.ts:3-181` | Use this tool to create and manage a structured task list for your current coding session. This helps you tra… |
| 4 | 10/18 | system | `services/compact/prompt.ts:61-143` | Your task is to create a detailed summary of the conversation so far, paying close attention to the user's ex… |
| 5 | 9/18 | command | `commands/commit-push-pr.ts:57-105` | ${prefix}## Context |
| 6 | 9/18 | tool | `tools/AgentTool/prompt.ts:115-154` | Example usage: |
| 7 | 9/18 | tool | `tools/AskUserQuestionTool/prompt.ts:32-44` | Use this tool when you need to ask the user questions during execution. This allows you to: |
| 8 | 8/18 | agent | `tools/AgentTool/built-in/statuslineSetup.ts:3-132` | You are a status line setup agent for Claude Code. Your job is to create or update the statusLine command in … |
| 9 | 8/18 | tool | `tools/EnterPlanModeTool/prompt.ts:108-163` | Use this tool when a task has genuine ambiguity about the right approach and getting user input before coding… |
| 10 | 8/18 | system | `services/compact/prompt.ts:145-204` | Your task is to create a detailed summary of the RECENT portion of the conversation — the messages that follo… |

## Flagged prompts (bottom 10)

| Score | Kind | Path | Red flags | Preview |
|---:|:---|:---|:---|:---|
| 3/18 | tool | `tools/GrepTool/prompt.ts:7-17` | NEVER without escape hatch | A powerful search tool built on ripgrep |
| 3/18 | tool | `tools/SkillTool/prompt.ts:174-195` | NEVER without escape hatch | Execute a skill within the main conversation |
| 4/18 | system | `constants/prompts.ts:766-770` | NEVER without escape hatch | Notes: |
| 4/18 | agent | `tools/AgentTool/built-in/generalPurposeAgent.ts:5-16` | hedging language present | Your strengths: |
| 4/18 | tool | `tools/WebFetchTool/prompt.ts:30-34` | NEVER without escape hatch | Provide a concise response based only on the content above. In your response: |
| 4/18 | tool | `tools/SendMessageTool/prompt.ts:11-20` | — | \n\n## Cross-session |
| 5/18 | system | `constants/prompts.ts:864-913` | hedging language present, NEVER without escape hatch | # Autonomous work |
| 5/18 | other | `buddy/prompt.ts:8-12` | hedging language present | # Companion |
| 5/18 | command | `commands/init.ts:6-26` | NEVER without escape hatch | Please analyze this codebase and create a CLAUDE.md file, which will be given to future instances of Claude C… |
| 5/18 | command | `commands/insights.ts:1738-1779` | hedging language present | You're writing an "At a Glance" summary for a Claude Code usage insights report for Claude Code users. The go… |

## Counts by kind

| Kind | Count | Avg chars | Avg lines |
|:---|---:|---:|---:|
| tool | 39 | 1,884 | 31.5 |
| skill | 15 | 3,391 | 70.4 |
| command | 12 | 4,360 | 74.0 |
| system | 11 | 1,661 | 28.3 |
| agent | 6 | 4,123 | 67.0 |
| other | 3 | 1,449 | 20.0 |
| hook | 2 | 650 | 11.5 |
| safety | 1 | 459 | 1.0 |
| memory | 1 | 989 | 7.0 |

## Priority-marker distribution

| Marker | Value -> Count of prompts |
|:---|:---|
| IMPORTANT per prompt | 0→67, 1→18, 2→2, 3→1, 4→1, 5→1 |
| NEVER per prompt | 0→76, 1→10, 2→1, 3→1, 4→1, 7→1 |
| CRITICAL per prompt | 0→79, 1→10, 2→1 |

## Top 10 files by prompt count

| File | Prompts |
|:---|---:|
| `constants/prompts.ts` | 6 |
| `services/compact/prompt.ts` | 5 |
| `tools/AgentTool/prompt.ts` | 5 |
| `skills/bundled/updateConfig.ts` | 4 |
| `commands/insights.ts` | 3 |
| `tools/EnterPlanModeTool/prompt.ts` | 3 |
| `tools/PowerShellTool/prompt.ts` | 3 |
| `tools/ScheduleCronTool/prompt.ts` | 3 |
| `commands/commit-push-pr.ts` | 2 |
| `commands/init.ts` | 2 |

## Top 10 files by total char length

| File | Total chars |
|:---|---:|
| `commands/init.ts` | 19,547 |
| `skills/bundled/updateConfig.ts` | 14,683 |
| `commands/security-review.ts` | 10,823 |
| `commands/init-verifiers.ts` | 9,761 |
| `tools/AgentTool/prompt.ts` | 9,683 |
| `tools/AgentTool/built-in/verificationAgent.ts` | 9,548 |
| `services/compact/prompt.ts` | 9,547 |
| `tools/TodoWriteTool/prompt.ts` | 9,132 |
| `constants/prompts.ts` | 8,723 |
| `skills/bundled/scheduleRemoteAgents.ts` | 8,092 |

## Stock phrase frequency

| Phrase | Count | Files |
|:---|---:|:---|
| don't gold-plate | 0 | — |
| smart colleague | 1 | `tools/AgentTool/prompt.ts` |
| measure twice, cut once | 0 | — |
| report in under 200 words | 1 | `tools/AgentTool/prompt.ts` |
| one sentence, don't use three | 1 | `constants/prompts.ts` |
| don't peek | 1 | `tools/AgentTool/prompt.ts` |
| never delegate understanding | 1 | `tools/AgentTool/prompt.ts` |
| first 80% | 1 | `tools/AgentTool/built-in/verificationAgent.ts` |

## XML tag usage

| Tag | Prompts using it |
|:---|---:|
| `<example>` | 8 |
| `<thinking>` | 1 |
| `<commentary>` | 2 |
| `<analysis>` | 4 |
| `<summary>` | 4 |
| `<system-reminder>` | 1 |

## VERDICT strings

Total `VERDICT: PASS/FAIL/PARTIAL` references across all prompts: **3**

