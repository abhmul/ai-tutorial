# Web discovery setup

Use this file to configure web/code/docs discovery for a specific project and harness. Keep `SKILL.md` focused on evidence behavior; keep install commands, backend choices, API keys, paths, and harness-specific tool mappings here or in a project-local setup note.

## Setup outcome

A completed setup should produce a reviewed project-local web discovery profile, stored somewhere the user approves, such as `AGENTS.md`, `.agents/web-discovery.md`, `.pi/web-discovery.md`, or another project note. The profile should state:

```md
# Web discovery local setup
- Network policy:
- Discovery commands:
  - web:
  - code:
  - docs:
  - other:
- Retrieval command:
- Raw fetch command, if allowed:
- Backends enabled:
- API keys or accounts needed, without secret values:
- Access limits and blocked source types:
- Citation/provenance expectations:
```

Do not record secret values in project files. Do not silently enable paid, account-based, or browser-automation backends.

## Requirement

The skill needs network permission and a search-plus-retrieval workflow:

- one command or tool action that finds candidate sources;
- one command or tool action that retrieves source text from a chosen source.

Discovery results are leads, not evidence. The agent should retrieve source text before relying on a claim. If no retrieval tool or network access is available, stay local or mark web-dependent claims as unsupported.

## Agent-guided setup procedure

1. Identify the current harness, available shell commands, network policy, and whether the project wants web, code, docs, literature, or other source classes.
2. Ask the user before installing software, changing global config, enabling paid/API backends, or storing credentials.
3. Choose Ketch or an equivalent workflow. Do not make Brave or any paid/API backend a hard prerequisite unless the user explicitly chooses that backend.
4. Configure only the backends the user intends to use.
5. Record the exact discovery and retrieval commands in the project-local web discovery profile.
6. Run a smoke test only after the user confirms network use is allowed.
7. If the smoke test fails, record the limitation and do not make web-backed claims until setup is fixed.

## Ketch option

[Ketch](https://github.com/1broseidon/ketch) can be installed by a documented path such as Homebrew, `go install github.com/1broseidon/ketch@latest`, or a GitHub release. After installation, initialize and inspect configuration:

```bash
ketch config init
ketch config
```

Use `ketch config` to inspect `~/.config/ketch/config.json` and the active backends. The common command mapping is:

```bash
ketch search <query>   # web discovery
ketch scrape <url>     # source-text retrieval
ketch code <query>     # code discovery
ketch docs <query>     # documentation discovery
```

Configure only the backends you intend to use. Ketch's default `brave` search backend needs a Brave Search API key. `ddg` is zero-config but may be rate-limited; `searxng` needs a SearXNG URL. For code search, Ketch documents `grepapp` and `sourcegraph` as zero-config backends, while the GitHub backend needs a token. For docs search, Context7 needs a `context7_api_key`.

Do not make Brave or any paid/API backend a hard prerequisite unless the task explicitly chooses that backend.

## Equivalent tools

If you do not use Ketch, provide the agent with explicit commands or tool calls for search and source retrieval. The replacement workflow should preserve the same evidence rule: search results identify candidates, and retrieved source text supports claims.

A sufficient setup record can be as simple as:

```md
- web discovery: <command that searches and returns URLs>
- source retrieval: <command that fetches/extracts a URL into readable text>
- code discovery: <optional command>
- docs discovery: <optional command>
```

Raw HTTP tools such as `curl` can be useful for APIs, downloads, headers, redirects, PDFs, or checking whether extraction is suspect, but raw fetch output still has to contain substantive source text before it supports a claim.

## Default policy for this repository

Policy version v0 does not configure `pi-web-access`, Perplexity, local extraction stacks, or browser automation as defaults. Add any of those only through a reviewed setup change that states the command, permissions, costs, and evidence limits.

If rendered/sessionful/browser retrieval is genuinely required and no reviewed setup supports it, stop and mark the source `needs-review`.

## Smoke test template

Use a harmless, low-stakes check after the user confirms network access is allowed:

```bash
<web discovery command> "example.com official example domain"
<retrieval command> "https://example.com/"
```

The smoke test succeeds only if discovery returns candidate URLs and retrieval returns substantive source text. If either step fails, record the failure in the setup profile and do not rely on web discovery for claims until fixed.
