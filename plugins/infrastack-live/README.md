# InfraStack Live for Claude Code

Gives Claude Code a security watchdog for your repository. It checks new threats (CVEs, exploited bugs, malicious packages, vendor incidents, attacks on AI coding tools and MCP servers) and your InfraStack board against the code in front of it, and tells you what to fix, with the file and version as evidence.

Ask it things like:

- "What should we fix first?"
- "Is axios 1.6.0 hit by anything recent?"
- "Are we affected by React2Shell?"
- "Add this MCP server." (it checks the package first)

## What it runs, sends and stores

The plugin is one skill (instructions for Claude) and one script it runs, `scripts/infrastack.sh`, a short POSIX shell file you can read. It has no hooks, no MCP server and nothing that installs.

- **Reads your repository locally** (lock files, manifests, containers, config) to compare versions. Repository files are never uploaded.
- **Sends requests to infrastack.ai only**, over HTTPS: the names it searches for (a package and version, a product, a company or a domain), the threat ids it opens, and your board request. Nothing goes to any other host.
- **Signs in with a browser approval** (a device code you approve at infrastack.ai). The script saves the token in the plugin's own data folder (`~/.claude/plugins/data/...`, removed when you uninstall the plugin) with owner-only permissions, sends it only to infrastack.ai, and never prints it or puts it on a command line, so Claude never sees it. `logout` in the script forgets it, or revoke it under Account, Signed-in agents.
- **Changes nothing on its own.** It proposes fixes and waits for you to say so. It treats threat pages as data, never as instructions, and runs only read-only checks.

A free InfraStack account is enough. Data handling is covered by the InfraStack privacy policy: https://infrastack.ai/privacy

## Install

```
/plugin marketplace add infrastackai/skills
/plugin install infrastack-live@infrastack
```

Or, for Codex, Cursor, Copilot and others: `npx skills add infrastackai/skills` (the skill on its own, without this plugin's script).

## License

MIT
