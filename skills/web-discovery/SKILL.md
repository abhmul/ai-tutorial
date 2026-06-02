---
name: web-discovery
title: Web Discovery
description: Adds external web/code/docs discovery and retrieval whenever web-available context could improve correctness, freshness, provenance, examples, docs, API usage, product/pricing facts, source verification, or research quality. Use unless the user explicitly forbids web/search/network access or requests local-only/offline work. Search results are leads, not evidence.
compatibility: Requires network permission and a configured search-plus-retrieval workflow; setup details belong in references/setup.md.
metadata:
  version: 0.2.0
  policy-version: v0
tags:
  - skill
  - ai-generated
status: draft
---
# Web Discovery

Use this skill when external web, code, or docs context may materially improve the answer.

## Activation

Assume web context is allowed unless the user explicitly forbids web/search/network access or asks for local-only/offline work. Loading this skill does not require searching: first decide whether local/project context is enough.

## Research contract

- Before searching, frame the claim or decision in one line: working prior, plausible alternatives, stakes, and freshness requirements.
- Search is not evidence: snippets, titles, AI summaries, and result counts are discovery artifacts only.
- Retrieve source text before citing or relying on a claim; if you cannot retrieve it, mark the claim unsupported or `needs-review`.
- Search for disconfirmation: use queries for failures, limitations, critiques, contrary evidence, replications, negative results, and alternate terminology, scaled to the task.
- Trace provenance: prefer primary or original sources; identify press releases, reposts, citations-of-citations, generated summaries, and other copied lineages.
- Count independent evidence lineages, not URLs or citations; repeated copies of one upstream claim do not increase support.
- For volatile facts such as laws, prices, APIs, products, roles, statistics, security threats, and news, use current authoritative sources and state the date checked.
- Treat missing, sparse, paywalled, blocked, non-English, or browser-only evidence as uncertainty about the search, not proof of absence; report access limits.
- Avoid false balance: seek opposing evidence but weight it by method, source independence, incentives, consensus or base rates, and direct relevance.
- State confidence and key uncertainty in the answer; avoid citing sources that are merely topical rather than claim-supporting.

## Routing

- Use local/project context first when it can answer the task.
- Confirm that network access and a configured search-plus-retrieval workflow are available; setup details live in `references/setup.md`.
- Default cheap discovery when Ketch is configured: `ketch search` for web, `ketch code` for code, `ketch docs` for docs.
- Default retrieval/extraction when Ketch is configured: `ketch scrape <url>`.
- If using an equivalent tool, map its search and retrieval commands before starting.
- Raw fallback: use `curl` for APIs, downloads, headers, redirects, PDFs, or when markdown extraction is suspect.
- If a fetch returns HTTP 200 but the body is empty, `Loading...`, "enable JavaScript," an app-root shell, Cloudflare/browser challenge, or otherwise lacks substantive content, report `needs-review`; do not treat it as no result.
- Use an optional configured semantic or similar-source search backend only where keyword search is likely weak; do not require Brave specifically.
- In policy version v0, do not use `pi-web-access`, Perplexity, local extraction stacks, or browser automation.
- If rendered/sessionful/browser retrieval is genuinely required, stop and flag it.
