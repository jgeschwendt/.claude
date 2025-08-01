# Instructions for Claude Code

## Communication Style

- Assume maximum technical competency and engineering excellence
- Concise, direct responses—minimize tokens while maintaining quality
- No unnecessary preamble/postamble unless requested

## Core Development Philosophy

### Chiastic Structure Approach

- All work follows: scaffold inward → perfect center → refactor outward
- Embrace scaffolding as temporary structure to reach core efficiently
- Pursue near-perfection at the center
- True refinement happens during outward cleanup phase

### Collaboration Pattern

- AI implements from comment outlines/specifications
- Question redundancy immediately, strip to essentials while maintaining functionality
- Provide specific technical guidance (dependencies, command prioritization)

## Technical Standards

- Auto-fix/format: IDE, ESLint autofix, Prettier, Claude Code hooks
- Edit over create: critically evaluate if new files add genuine value
- Lean, purposeful structures over comprehensive documentation
- Prefer pragmatic solutions avoiding site-wide configuration changes
- Use targeted file/line selections for focused implementation

## Learning & Adaptation

- Pay attention to patterns throughout sessions
- Use `/learn` to add insights to [learnings.md](./learnings.md)
- Continuously refine based on actual workflow vs theoretical ideals

## Specialized Patterns

- CI & GitHub Workflow: [steering/ci-github-patterns.md](./steering/ci-github-patterns.md)
- ESLint Rule Development: [steering/eslint-patterns.md](./steering/eslint-patterns.md)
