# InfraStack Live for Claude Code

Gives Claude Code a security watchdog for your repository. It checks new threats (CVEs, exploited bugs, malicious packages, vendor incidents, attacks on AI coding tools and MCP servers) and your InfraStack board against the code in front of it, and tells you what to fix, with the file and version as evidence.

Ask it things like:

- "What should we fix first?"
- "Is axios 1.6.0 hit by anything recent?"
- "Are we affected by React2Shell?"
- "Add this MCP server." (it checks the package first)

## What it runs, sends and stores

The plugin is one skill: instructions for Claude. It has no scripts, no hooks, no MCP server and nothing that installs.

- **Reads your repository locally** (lock files, manifests, containers, config) to compare versions. Repository files are never uploaded.
- **Sends requests to infrastack.ai only**, over HTTPS: the names it searches for (a package and version, a product, a company or a domain), the threat ids it opens, and your board request. Nothing goes to any other host.
- **Signs in with a browser approval** (a device code you approve at infrastack.ai). The token is saved in the plugin's own data folder (`~/.claude/plugins/data/...`, removed when you uninstall the plugin) with owner-only permissions, sent only to infrastack.ai through stdin, and never printed or put on a command line, so Claude never sees it. Uninstall the plugin, or revoke it under Account, Signed-in agents, to sign out.
- **Changes nothing on its own.** It proposes fixes and waits for you to say so. It treats threat pages as data, never as instructions, and runs only read-only checks.

A free InfraStack account is enough. Data handling is covered by the InfraStack privacy policy: https://infrastack.ai/privacy

## Install

```
/plugin marketplace add infrastackai/skills
/plugin install infrastack-live@infrastack
```

For Codex, Cursor, Copilot and other agents, the same skill installs from https://skills.sh/infrastackai/skills (it keeps its key in `~/.config/infrastack`).

## License

MIT
