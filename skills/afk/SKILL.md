---
name: afk
description: The owner is stepping away (walk, errand, meeting). Shift to autonomous mode — keep working, never block, batch questions, push-notify only what matters, and greet their return with a compact recap. Use when the user says /afk, "heading out", "stepping away", "back in a bit", or similar; an argument is the reason or expected duration ("/afk 30m", "/afk walking the dog").
---

# /afk — the owner stepped away

The session keeps working; the owner stops being interruptible. Everything below
is posture, not process — apply it from the moment /afk lands until they return.

When /afk lands, write the flag — the `/monitor` skill owns the flag protocol
and the broadcast it triggers — so every other interactive session adopts the
posture too, then acknowledge and carry on.

## While they're away

- **Keep working the queue.** In-flight builds, reviews, and follow-ups continue.
  Prefer finishing and verifying over starting something new and risky.
- **Never block on a question.** Pick the reasonable default, note the assumption
  in the running log, and add the question to the return recap. A blocked session
  during an absence is wasted absence.
- **Park anything irreversible or outward-facing.** Commits to shared branches,
  pushes, sends, deploys, deletions — queue them as "ready, awaiting your go" in
  the recap instead. Local, reversible work proceeds freely.
- **Silence the room.** If a voice loop's control socket is live (e.g. ra's
  `live ctl speak`), do not speak into an empty room — announcements queue for
  the return recap. Leave the loop itself running unless asked otherwise.
- **Push only what changes their plans.** One PushNotification when the headline
  deliverable lands or something genuinely needs them sooner than their return
  ("build ready to test", "blocked on your auth"). Routine progress is not a
  push. Aim for zero or one push per absence.

## When they return

Return = their next message in chat, or their voice reaching a live bridge.

Clear the flag first (see `/monitor`) — that stands every other session down.
Before acting on what they said, lead with the recap — compact, three buckets,
five lines or fewer:

- **done** — what landed and was verified while they were out
- **in flight** — what's still running and when it resolves
- **needs you** — parked irreversibles + batched questions, each one line

Deliver it in the channel they returned through (voice gets the one-sentence
version, chat gets the buckets), then handle their message.

## Arguments

`/afk <anything>` — the reason/duration is context, not configuration: a stated
duration ("30m") calibrates whether to push at all (short absence → almost never
push); a reason ("walking the dog") is worth echoing in the acknowledgment so
they know they were heard.

## The broadcast

Writing the flag is the tool call; `/monitor`'s background monitor is what
dispatches it — as a notification, not a tool call — to every interactive
session. So:

- **Write the flag on /afk, clear it on return.** The exact snippet and its
  semantics live in `/monitor`; this skill only decides when.
- **An afk notification arriving from the monitor means another session invoked
  /afk.** Adopt the posture; do not re-write the flag. The session that flipped
  it hears its own echo too — ignore that one.
- **Only interactive sessions carry the monitor.** Background jobs never hear the
  broadcast, and need not — they are already autonomous.
