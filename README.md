# InfraStack skills

Agent skills from [InfraStack](https://infrastack.ai) for Claude Code, Codex, Cursor, OpenCode and GitHub Copilot.

## infrastack-live

Threat intel for your coding agent. Your agent checks new security threats against your repository: CVEs, exploited bugs, malicious packages, vendor incidents, and attacks on AI coding tools and MCP servers. It checks before it adds or upgrades a dependency, whenever you ask about a CVE or a package, and on a schedule if you ask.

It reads [InfraStack Live](https://infrastack.ai/live), a free public feed with one markdown page per threat: who is affected, the affected versions, how to check, and the fix. Plain HTTPS. No MCP server, no login, no API key. Your code never leaves your machine; your agent only reads public pages.

### Install

With the skills CLI:

```sh
npx skills add infrastackai/skills --skill infrastack-live
```

Or by hand, from your repository root:

| Agent | Command |
| --- | --- |
| Claude Code | `mkdir -p .claude/skills/infrastack-live && curl -fsSL https://infrastack.ai/live/SKILL.md -o .claude/skills/infrastack-live/SKILL.md` |
| Codex, OpenCode | `curl -fsSL "https://infrastack.ai/live/SKILL.md?plain=1" >> AGENTS.md` |
| Cursor | `mkdir -p .cursor/rules && curl -fsSL https://infrastack.ai/live/SKILL.md -o .cursor/rules/infrastack-live.mdc` |
| GitHub Copilot | `mkdir -p .github && curl -fsSL "https://infrastack.ai/live/SKILL.md?plain=1" >> .github/copilot-instructions.md` |

Or paste one sentence into any agent:

> Read https://infrastack.ai/live/SKILL.md and set yourself up with it for this repository.

### Then ask

- "Scan this repo against infrastack.ai/live and tell me which threats hit what we run."
- "Are we affected by React2Shell?"
- "Every morning, check infrastack.ai/live and tell me the day a new threat hits our stack."

### What it reads

- `https://infrastack.ai/live.md`: the feed, one line per threat
- `https://infrastack.ai/live/search.md?q=next.js, postgres, stripe`: search several packages at once
- `https://infrastack.ai/live/<id>/threat.md`: one threat, with who is affected, how to check and the fix
- `https://infrastack.ai/llms.txt`: the map of everything

Every page has a `.json` twin.

## More

- [infrastack.ai/coding-agents](https://infrastack.ai/coding-agents): the skill, the MCP and AI agent threats it knows about, and questions
- Alerts without asking, by email or in Slack: [infrastack.ai](https://infrastack.ai)

Free to use at a human pace. For higher limits or API access: sales@infrastack.ai.
