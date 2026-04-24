# Prompt Corpus Index

Source: `/Users/jlg/.grove/code/NanmiCoder/cc-haha/initial/src`
Extracted: 2026-04-24
Total prompts: 90

## By kind

### Tool prompts (39)

- `tools/AgentTool/prompt.ts:81-96` — **prompt** (1,806 chars, 16 lines) — ## When to fork
- `tools/AgentTool/prompt.ts:99-113` — **writingThePromptSection** (1,182 chars, 15 lines, dynamic) — ## Writing the prompt
- `tools/AgentTool/prompt.ts:115-154` — **forkExamples** (2,349 chars, 40 lines, dynamic) — Example usage:
- `tools/AgentTool/prompt.ts:156-188` — **currentExamples** (1,046 chars, 33 lines, dynamic) — Example usage:
- `tools/AgentTool/prompt.ts:252-286` — **prompt** (3,300 chars, 35 lines, dynamic) — ${shared}
- `tools/AskUserQuestionTool/prompt.ts:32-44` — **ASK_USER_QUESTION_TOOL_PROMPT** (1,119 chars, 13 lines, dynamic) — Use this tool when you need to ask the user questions during execution. This allows you to:
- `tools/BashTool/prompt.ts:68-75` — **prompt** (448 chars, 8 lines, dynamic) — ${undercoverSection}# Git operations
- `tools/BashTool/prompt.ts:81-160` — **prompt** (6,305 chars, 80 lines, dynamic) — # Committing changes with git
- `tools/BriefTool/prompt.ts:12-22` — **BRIEF_PROACTIVE_SECTION** (1,143 chars, 11 lines, dynamic) — ## Talking to the user
- `tools/ConfigTool/prompt.ts:50-76` — **prompt** (954 chars, 27 lines, dynamic) — Get or set Claude Code configuration settings.
- `tools/EnterPlanModeTool/prompt.ts:4-14` — **WHAT_HAPPENS_SECTION** (385 chars, 11 lines, dynamic) — ## What Happens in Plan Mode
- `tools/EnterPlanModeTool/prompt.ts:23-98` — **prompt** (3,681 chars, 76 lines, dynamic) — Use this tool proactively when you're about to start a non-trivial implementation task. Getting user
- `tools/EnterPlanModeTool/prompt.ts:108-163` — **prompt** (2,671 chars, 56 lines, dynamic) — Use this tool when a task has genuine ambiguity about the right approach and getting user input befo
- `tools/EnterWorktreeTool/prompt.ts:2-29` — **prompt** (1,335 chars, 28 lines) — Use this tool ONLY when the user explicitly asks to work in a worktree. This tool creates an isolate
- `tools/ExitPlanModeTool/prompt.ts:6-29` — **EXIT_PLAN_MODE_V2_TOOL_PROMPT** (1,894 chars, 24 lines, dynamic) — Use this tool when you are in plan mode and have finished writing your plan to the plan file and are
- `tools/ExitWorktreeTool/prompt.ts:2-31` — **prompt** (1,923 chars, 30 lines) — Exit a worktree session created by EnterWorktree and return the session to the original working dire
- `tools/FileEditTool/prompt.ts:20-27` — **prompt** (990 chars, 8 lines, dynamic) — Performs exact string replacements in files.
- `tools/FileReadTool/prompt.ts:32-48` — **prompt** (1,573 chars, 17 lines, dynamic) — Reads a file from the local filesystem. You can access any file directly by using this tool.
- `tools/FileWriteTool/prompt.ts:11-17` — **prompt** (500 chars, 7 lines, dynamic) — Writes a file to the local filesystem.
- `tools/GrepTool/prompt.ts:7-17` — **prompt** (925 chars, 11 lines, dynamic) — A powerful search tool built on ripgrep
- `tools/PowerShellTool/prompt.ts:53-58` — **prompt** (917 chars, 6 lines) — PowerShell edition: Windows PowerShell 5.1 (powershell.exe)
- `tools/PowerShellTool/prompt.ts:68-70` — **prompt** (304 chars, 3 lines) — PowerShell edition: unknown — assume Windows PowerShell 5.1 for compatibility
- `tools/PowerShellTool/prompt.ts:78-144` — **prompt** (5,138 chars, 67 lines, dynamic) — Executes a given PowerShell command with optional timeout. Working directory persists between comman
- `tools/ScheduleCronTool/prompt.ts:76-78` — **prompt** (469 chars, 3 lines) — ## Durability
- `tools/ScheduleCronTool/prompt.ts:79-81` — **prompt** (123 chars, 3 lines) — ## Session-only
- `tools/ScheduleCronTool/prompt.ts:87-120` — **prompt** (2,295 chars, 34 lines, dynamic) — Schedule a prompt to be enqueued at a future time. Use for both recurring schedules and one-shot rem
- `tools/SendMessageTool/prompt.ts:11-20` — **prompt** (515 chars, 10 lines) — \n\n## Cross-session
- `tools/SendMessageTool/prompt.ts:22-48` — **prompt** (1,321 chars, 27 lines, dynamic) — # SendMessage
- `tools/SkillTool/prompt.ts:174-195` — **prompt** (1,279 chars, 22 lines, dynamic) — Execute a skill within the main conversation
- `tools/TaskCreateTool/prompt.ts:16-55` — **prompt** (2,179 chars, 40 lines, dynamic) — Use this tool to create a structured task list for your current coding session. This helps you track
- `tools/TaskGetTool/prompt.ts:3-24` — **PROMPT** (732 chars, 22 lines) — Use this tool to retrieve a task by its ID from the task list.
- `tools/TaskListTool/prompt.ts:16-25` — **prompt** (503 chars, 10 lines) — ## Teammate Workflow
- `tools/TaskListTool/prompt.ts:28-48` — **prompt** (995 chars, 21 lines, dynamic) — Use this tool to list all tasks in the task list.
- `tools/TaskUpdateTool/prompt.ts:3-77` — **PROMPT** (2,243 chars, 75 lines) — Use this tool to update a task in the task list.
- `tools/TeamCreateTool/prompt.ts:2-112` — **prompt** (6,775 chars, 111 lines) — # TeamCreate
- `tools/TodoWriteTool/prompt.ts:3-181` — **PROMPT** (9,132 chars, 179 lines, dynamic) — Use this tool to create and manage a structured task list for your current coding session. This help
- `tools/WebFetchTool/prompt.ts:3-21` — **DESCRIPTION** (1,217 chars, 19 lines) — - Fetches content from a specified URL and processes it using an AI model
- `tools/WebFetchTool/prompt.ts:30-34` — **prompt** (495 chars, 5 lines) — Provide a concise response based only on the content above. In your response:
- `tools/WebSearchTool/prompt.ts:7-33` — **prompt** (1,327 chars, 27 lines, dynamic) — - Allows Claude to search the web and use the results to inform responses

### Agent persona prompts (6)

- `tools/AgentTool/built-in/claudeCodeGuideAgent.ts:30-86` — **claudeCodeGuideAgent** (3,012 chars, 57 lines, dynamic) — You are the Claude guide agent. Your primary responsibility is helping users understand and use Clau
- `tools/AgentTool/built-in/exploreAgent.ts:24-56` — **exploreAgent** (1,959 chars, 33 lines, dynamic) — You are a file search specialist for Claude Code, Anthropic's official CLI for Claude. You excel at 
- `tools/AgentTool/built-in/generalPurposeAgent.ts:5-16` — **SHARED_GUIDELINES** (884 chars, 12 lines) — Your strengths:
- `tools/AgentTool/built-in/planAgent.ts:21-70` — **planAgent** (2,341 chars, 50 lines, dynamic) — You are a software architect and planning specialist for Claude Code. Your role is to explore the co
- `tools/AgentTool/built-in/statuslineSetup.ts:3-132` — **STATUSLINE_SYSTEM_PROMPT** (6,994 chars, 130 lines) — You are a status line setup agent for Claude Code. Your job is to create or update the statusLine co
- `tools/AgentTool/built-in/verificationAgent.ts:10-129` — **VERIFICATION_SYSTEM_PROMPT** (9,548 chars, 120 lines, dynamic) — You are a verification specialist. Your job is not to confirm the implementation works — it's to try

### Skill prompts (15)

- `skills/bundled/batch.ts:20-88` — **batch** (4,123 chars, 69 lines, dynamic) — # Batch: Parallel Work Orchestration
- `skills/bundled/claudeApi.ts:96-130` — **INLINE_READING_GUIDE** (1,435 chars, 35 lines) — ## Reference Documentation
- `skills/bundled/claudeInChrome.ts:10-14` — **SKILL_ACTIVATION_MESSAGE** (291 chars, 5 lines) — Now that this skill is invoked, you have access to Chrome browser automation tools. You can now use 
- `skills/bundled/debug.ts:61-67` — **debug** (360 chars, 7 lines, dynamic) — ## Debug Logging Just Enabled
- `skills/bundled/debug.ts:69-99` — **prompt** (1,098 chars, 31 lines, dynamic) — # Debug Skill
- `skills/bundled/loop.ts:26-71` — **loop** (2,999 chars, 46 lines, dynamic) — # /loop — schedule a recurring prompt
- `skills/bundled/remember.ts:9-62` — **SKILL_PROMPT** (3,190 chars, 54 lines) — # Memory Review
- `skills/bundled/scheduleRemoteAgents.ts:174-321` — **scheduleRemoteAgents** (8,092 chars, 148 lines, dynamic) — # Schedule Remote Agents
- `skills/bundled/simplify.ts:4-53` — **SIMPLIFY_PROMPT** (3,846 chars, 50 lines, dynamic) — # Simplify: Code Review and Cleanup
- `skills/bundled/skillify.ts:22-156` — **SKILLIFY_PROMPT** (7,381 chars, 135 lines) — # Skillify {{userDescriptionBlock}}
- `skills/bundled/stuck.ts:6-59` — **STUCK_PROMPT** (3,363 chars, 54 lines) — # /stuck — diagnose frozen/slow Claude Code sessions
- `skills/bundled/updateConfig.ts:15-104` — **SETTINGS_EXAMPLES_DOCS** (2,405 chars, 90 lines) — ## Settings File Locations
- `skills/bundled/updateConfig.ts:110-267` — **HOOKS_DOCS** (4,258 chars, 158 lines) — ## Hooks Configuration
- `skills/bundled/updateConfig.ts:269-305` — **HOOK_VERIFICATION_FLOW** (3,889 chars, 37 lines) — ## Constructing a Hook (with verification)
- `skills/bundled/updateConfig.ts:307-443` — **UPDATE_CONFIG_PROMPT** (4,131 chars, 137 lines, dynamic) — # Update Config Skill

### Command prompts (12)

- `commands/commit-push-pr.ts:40-45` — **changelogSection** (165 chars, 6 lines) — ## Changelog
- `commands/commit-push-pr.ts:57-105` — **commit-push-pr** (2,563 chars, 49 lines, dynamic) — ${prefix}## Context
- `commands/commit.ts:20-54` — **commit** (1,912 chars, 35 lines, dynamic) — ${prefix}## Context
- `commands/init-verifiers.ts:15-256` — **init-verifiers** (9,761 chars, 242 lines) — Use the TodoWrite tool to track your progress through this multi-step task.
- `commands/init.ts:6-26` — **OLD_INIT_PROMPT** (1,592 chars, 21 lines) — Please analyze this codebase and create a CLAUDE.md file, which will be given to future instances of
- `commands/init.ts:28-224` — **NEW_INIT_PROMPT** (17,955 chars, 197 lines) — Set up a minimal CLAUDE.md (and optionally skills and hooks) for this repo. CLAUDE.md is loaded into
- `commands/insights.ts:1394-1432` — **insights** (2,663 chars, 39 lines) — Analyze this Claude Code usage data and suggest improvements.
- `commands/insights.ts:1738-1779` — **atAGlancePrompt** (2,186 chars, 42 lines, dynamic) — You're writing an "At a Glance" summary for a Claude Code usage insights report for Claude Code user
- `commands/insights.ts:3133-3141` — **insights** (481 chars, 9 lines, dynamic) — ## At a Glance
- `commands/pr_comments/index.ts:13-46` — **index** (1,383 chars, 34 lines, dynamic) — You are an AI assistant integrated into a git-based version control system. Your task is to fetch an
- `commands/review.ts:9-31` — **review** (833 chars, 23 lines, dynamic) — You are an expert code reviewer. Follow these steps:
- `commands/security-review.ts:6-196` — **SECURITY_REVIEW_MARKDOWN** (10,823 chars, 191 lines) — ---

### System / composition prompts (11)

- `constants/prompts.ts:179-183` — **prompts** (534 chars, 5 lines, dynamic) — You are an interactive agent that helps users ${outputStyleConfig !== null ? 'according to your "Out
- `constants/prompts.ts:405-414` — **prompts** (2,395 chars, 10 lines) — # Communicating with the user
- `constants/prompts.ts:416-427` — **prompts** (730 chars, 12 lines) — # Output efficiency
- `constants/prompts.ts:766-770` — **notes** (630 chars, 5 lines) — Notes:
- `constants/prompts.ts:804-818` — **prompts** (668 chars, 15 lines, dynamic) — # Scratchpad Directory
- `constants/prompts.ts:864-913` — **prompts** (3,766 chars, 50 lines, dynamic) — # Autonomous work
- `services/compact/prompt.ts:19-26` — **NO_TOOLS_PREAMBLE** (379 chars, 8 lines) — CRITICAL: Respond with TEXT ONLY. Do NOT call any tools.
- `services/compact/prompt.ts:61-143` — **BASE_COMPACT_PROMPT** (4,220 chars, 83 lines, dynamic) — Your task is to create a detailed summary of the conversation so far, paying close attention to the 
- `services/compact/prompt.ts:145-204` — **PARTIAL_COMPACT_PROMPT** (2,362 chars, 60 lines, dynamic) — Your task is to create a detailed summary of the RECENT portion of the conversation — the messages t
- `services/compact/prompt.ts:208-267` — **PARTIAL_COMPACT_UP_TO_PROMPT** (2,326 chars, 60 lines, dynamic) — Your task is to create a detailed summary of this conversation. This summary will be placed at the s
- `services/compact/prompt.ts:365-367` — **prompt** (260 chars, 3 lines) — You are running in autonomous/proactive mode. This is NOT a first wake-up — you were already working

### Safety prompts (1)

- `constants/cyberRiskInstruction.ts:24-24` — **CYBER_RISK_INSTRUCTION** (459 chars, 1 lines) — IMPORTANT: Assist with authorized security testing, defensive security, CTF challenges, and educatio

### Hook prompts (2)

- `utils/hooks/execPromptHook.ts:65-69` — **execPromptHook** (262 chars, 5 lines) — You are evaluating a hook in Claude Code.
- `utils/sideQuestion.ts:61-78` — **wrappedQuestion** (1,038 chars, 18 lines, dynamic) — <system-reminder>This is a side question from the user. You must answer this question directly in a 

### Memory taxonomy prompts (1)

- `memdir/findRelevantMemories.ts:18-24` — **SELECT_MEMORIES_SYSTEM_PROMPT** (989 chars, 7 lines) — You are selecting memories that will be useful to Claude Code as it processes a user's query. You wi

### Other (3)

- `buddy/prompt.ts:8-12` — **prompt** (496 chars, 5 lines, dynamic) — # Companion
- `utils/claudeInChrome/prompt.ts:1-46` — **BASE_CHROME_PROMPT** (3,353 chars, 46 lines) — # Claude in Chrome browser automation
- `utils/claudeInChrome/prompt.ts:53-61` — **CHROME_TOOL_SEARCH_INSTRUCTIONS** (499 chars, 9 lines) — **IMPORTANT: Before using any chrome browser tools, you MUST first load them using ToolSearch.**

