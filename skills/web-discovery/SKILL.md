---
name: web-discovery
title: Web Discovery
description: Adds external web/code/docs discovery and retrieval whenever web-available context could improve correctness, freshness, provenance, examples, docs, API usage, product/pricing facts, source verification, or research quality. Use unless the user explicitly forbids web/search/network access or requests local-only/offline work. Search results are leads, not evidence.
compatibility: Requires network permission and a configured search-plus-retrieval workflow; setup guidance lives in SETUP.md.
metadata:
  version: 0.3.0
  policy-version: v0
tags:
  - skill
  - ai-generated
status: draft
---
# Web Discovery

Use this skill when external web, code, or docs context may materially improve the answer.

## Setup boundary

This `SKILL.md` defines when to seek external context and how to treat evidence. It intentionally does not install, choose, or hard-code a search or retrieval backend. Use the search-plus-retrieval workflow configured for the current project and harness. If no workflow is configured, if network permission is unavailable, or if the user asks to set up web discovery, read `SETUP.md` and guide the user through setup before making web-backed claims.

Search results are leads, not evidence. Retrieved source text is the minimum evidence needed before relying on or citing a web claim.

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

## Workflow

1. Use local/project context first when it can answer the task.
2. If external context may materially help, frame the claim or decision before searching.
3. Confirm that network access and a configured search-plus-retrieval workflow are available. If not, read `SETUP.md` for setup help or mark web-dependent claims unsupported.
4. Use the configured discovery command for the needed source class: web, code, docs, literature, or another project-approved source class.
5. Treat discovery output only as candidate-source leads. Select sources by authority, independence, directness, recency, and relevance.
6. Retrieve source text using the configured retrieval command before relying on a claim.
7. If retrieval returns HTTP 200 but the body is empty, `Loading...`, "enable JavaScript," an app-root shell, a browser challenge, or otherwise lacks substantive content, report `needs-review`; do not treat it as no result.
8. If rendered, sessionful, or browser retrieval is genuinely required and no reviewed setup supports it, stop and flag the limitation.
9. Synthesize with provenance, confidence, and uncertainty. Cite or name only sources that actually support the specific claim.

Use only the configured workflow for the current project. Do not substitute unreviewed web tools, paid/API backends, browser automation, or generated answer engines merely because they are available in another environment.
