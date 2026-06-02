# Web discovery setup

Use this file for installation and configuration details. Keep `SKILL.md` focused on when and how the agent should use web discovery.

## Requirement

The skill needs network permission and either Ketch or an equivalent search-plus-retrieval workflow:

- one command that finds candidate sources;
- one command that retrieves source text from a chosen source.

Discovery results are leads, not evidence. The agent should retrieve source text before relying on a claim.

## Ketch option

[Ketch](https://github.com/1broseidon/ketch) can be installed by a documented path such as Homebrew, `go install github.com/1broseidon/ketch@latest`, or a GitHub release. After installation, run:

```bash
ketch config init
ketch config
```

Use `ketch config` to inspect `~/.config/ketch/config.json` and the active backends. The commands used by the skill are:

```bash
ketch search <query>
ketch scrape <url>
ketch code <query>
ketch docs <query>
```

Configure only the backends you intend to use. Ketch's default `brave` search backend needs a Brave Search API key. `ddg` is zero-config but may be rate-limited; `searxng` needs a SearXNG URL. For code search, Ketch documents `grepapp` and `sourcegraph` as zero-config backends, while the GitHub backend needs a token. For docs search, Context7 needs a `context7_api_key`.

Do not make Brave or any paid/API backend a hard prerequisite unless the task explicitly chooses that backend.

## Equivalent tools

If you do not use Ketch, provide the agent with explicit commands for search and source retrieval. The replacement workflow should preserve the same evidence rule: search results identify candidates, and retrieved source text supports claims.

If no retrieval tool or network access is available, stay local or mark web-dependent claims as unsupported.
