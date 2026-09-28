---
name: herdr-agents
description: Start, prompt and read other coding agents (Codex, OpenCode, Claude Code) in herdr panes using Jason's named presets (qwen, sol, terra, astra, glm, kimi, claude, opus...). Use when asked to spin up, delegate to, or hand work to another agent/model/harness ("have codex review this", "farm the tests out to qwen", "start a sol agent"). Requires HERDR_ENV=1.
---

# herdr agent presets

Jason's presets live in `~/.config/herdr/agents.json` and are launched by `ha` (on PATH). **Always start agents through `ha`.** Never assemble `herdr agent start --kind … -- <model flags>` by hand: `ha` handles model flags, pane placement, unique names, and Bedrock auth.

- `ha`: list presets (name, harness, description). Run this first if unsure which preset fits.
- `ha <preset> [name]`: split the calling pane and start the agent. It prints `started <name> (<kind> …) in <pane>`. The name defaults to the preset (`qwen`, `qwen-2`, …).

Routing rules (Jason, 2026-09-28):
- **Claude work stays on Claude presets** (`claude`, `opus`). They run on the Teams subscription, and `ha` never injects Bedrock auth into them. Never export `CLAUDE_CODE_USE_BEDROCK` or `eval "$(bedrock-token)"` in a Claude pane.
- **OpenAI models are Codex presets** (`luna` fast/cheap, `terra` everyday, `sol` hard multi-step, `astra` frontier). **Qwen, GLM, Kimi and other open-weight models are OpenCode presets.** All of these bill to Bedrock (US-only profiles); `ha` injects a fresh token into that pane only.
- Pick the cheapest preset that fits the task. If a task needs a model with no preset, tell Jason and suggest a new `agents.json` entry rather than improvising flags.

Once an agent is running, drive it with the herdr agent commands (see the `herdr` skill for full semantics):

```bash
herdr agent prompt <name> "<task>" --wait --timeout 600000
herdr agent read <name> --source recent-unwrapped --lines 120
herdr agent get <name>        # status: idle | working | blocked | done | unknown
```

- The first prompt right after `ha` returns can race the harness's startup screen. If `read` shows the prompt wasn't taken, wait a moment and resend.
- On `blocked` (an approval or question in the other agent), read it and ask Jason before answering on the agent's behalf.
- Don't close panes you didn't create. When your delegated work is done, tell Jason which agents are still running rather than killing them.
