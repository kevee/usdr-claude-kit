---
name: security-rules-sync
description: >-
  Assess the current codebase and add matching secure-coding rules from the
  TikiTribe/claude-secure-coding-rules catalog (OWASP, AI/ML, agent, MCP, RAG,
  and per-language/framework/infra rules). Detects the stack, proposes a matched
  rule set for approval, then downloads it — importing foundational rules into
  CLAUDE.md and storing stack-specific rules under .claude/security-rules/ for
  on-demand use. Use when the user wants to add, refresh, or review security
  rules for this repo, harden the project, or "figure out which security rules
  apply."
allowed-tools: Bash Read Edit Write Glob Grep
---

# security-rules-sync

Match this repo's stack to the secure-coding rules published at
[TikiTribe/claude-secure-coding-rules](https://github.com/TikiTribe/claude-secure-coding-rules)
(MIT), then add only the rules that apply. The catalog holds `_core` foundation
files plus per-language, framework, frontend, CI/CD, container, IaC, and RAG rule
sets (each `CLAUDE.md`).

Rule files are large (10–38KB each), so activation is split:

- **Always-on ---** matched `rules/_core/*` files import into `.claude/CLAUDE.md`, so they apply every session.
- **On-demand ---** everything else lands under `.claude/security-rules/`; consult the matching file when you write, review, or refactor code in that area.

Always **propose the matched set and get approval before downloading.**

## Workflow

### 1. Assess the stack

Run the scanner and read its report:

```sh
bash .claude/skills/security-rules-sync/scripts/assess.sh
```

It reports file-extension counts, marker/manifest files (`package.json`,
`requirements.txt`, `Dockerfile`, `*.tf`, `.github/workflows/`, …), and dumps
dependency manifests. Read the manifest contents to identify frameworks and
libraries — don't rely on extensions alone (e.g. `.py` files could be Django,
FastAPI, LangChain, or plain scripts).

If the report is sparse (a config/docs-only repo, like a starter kit), that's
fine — still offer the always-on core rules plus any CI/CD or container rules
that match.

### 2. Fetch the live catalog

Confirm which rule paths actually exist upstream at the pinned commit, so you
never propose a file that 404s and you can discover newly added tools:

```sh
curl -sSL "https://api.github.com/repos/TikiTribe/claude-secure-coding-rules/git/trees/f644d862f89f926537591d64439c067b1e066ffe?recursive=1" \
  | python3 -c "import sys,json;[print(t['path']) for t in json.load(sys.stdin)['tree'] if t['path'].startswith('rules/') and t['path'].endswith('.md')]"
```

Intersect your matches with this list. The mapping table below is the maintained
guide; the live tree is ground truth. If you detect a tool that has a rule dir
you don't see in the table, match it by name.

### 3. Map detections to rule paths

Use this table. Detect frameworks/libraries from the **manifest contents**, not
just file extensions.

**Always-on core** (`rules/_core/` → import into CLAUDE.md):

| Signal | Rule path |
| --- | --- |
| Any code at all (always) | `rules/_core/owasp-2025.md` |
| AI/ML libs (torch, tensorflow, transformers, sklearn, vllm, keras, onnx) | `rules/_core/ai-security.md` |
| Agentic (langchain agents, crewai, autogen, tool-use, `mcp` agent) | `rules/_core/agent-security.md` |
| MCP server/client (`mcp`, `modelcontextprotocol`, `.mcp.json`) | `rules/_core/mcp-security.md` |
| RAG (vector store / embeddings / retrieval libs — see RAG rows) | `rules/_core/rag-security.md` |
| Graph DB (neo4j, memgraph, arangodb, neptune, tigergraph) | `rules/_core/graph-database-security.md` |

**On-demand** (→ `.claude/security-rules/`, not imported):

| Signal | Rule path |
| --- | --- |
| `.py` / requirements / pyproject / Pipfile | `rules/languages/python/CLAUDE.md` |
| `.js` | `rules/languages/javascript/CLAUDE.md` |
| `.ts` / `.tsx` | `rules/languages/typescript/CLAUDE.md` |
| `.go` / go.mod | `rules/languages/go/CLAUDE.md` |
| `.rs` / Cargo.toml | `rules/languages/rust/CLAUDE.md` |
| `.java` / pom.xml / build.gradle | `rules/languages/java/CLAUDE.md` |
| `.cs` / *.csproj | `rules/languages/csharp/CLAUDE.md` |
| `.rb` / Gemfile | `rules/languages/ruby/CLAUDE.md` |
| `.r` / `.R` / DESCRIPTION | `rules/languages/r/CLAUDE.md` |
| `.cpp` / `.cc` / `.hpp` | `rules/languages/cpp/CLAUDE.md` |
| `.jl` / Project.toml | `rules/languages/julia/CLAUDE.md` |
| `.sql` or SQL client libs | `rules/languages/sql/CLAUDE.md` |
| fastapi / flask / django / express / nestjs | `rules/backend/<framework>/CLAUDE.md` |
| langchain / crewai / autogen / transformers / vllm / triton / torchserve / ray[serve] / bentoml / mlflow / modal | `rules/backend/<tool>/CLAUDE.md` (`ray[serve]`→`ray-serve`) |
| react / next / vue / svelte / angular | `rules/frontend/<framework>/CLAUDE.md` (`next`→`nextjs`) |
| `.github/workflows/` present | `rules/cicd/github-actions/CLAUDE.md` + `rules/cicd/_core/cicd-security.md` |
| `.gitlab-ci.yml` | `rules/cicd/gitlab-ci/CLAUDE.md` + `rules/cicd/_core/cicd-security.md` |
| Dockerfile / compose | `rules/containers/docker/CLAUDE.md` + `rules/containers/_core/container-security.md` |
| Kubernetes manifests | `rules/containers/kubernetes/CLAUDE.md` + `rules/containers/_core/container-security.md` |
| Chart.yaml (Helm) | `rules/containers/helm/CLAUDE.md` + `rules/containers/_core/container-security.md` |
| `*.tf` (Terraform) | `rules/iac/terraform/CLAUDE.md` + `rules/iac/_core/iac-security.md` |
| Pulumi.yaml | `rules/iac/pulumi/CLAUDE.md` + `rules/iac/_core/iac-security.md` |
| RAG orchestration (llamaindex, haystack, dspy/txtai/ragas, langchain loaders) | `rules/rag/orchestration/<tool>/CLAUDE.md` + `rules/rag/_core/*` |
| Managed vector DB (pinecone, weaviate-cloud, mongodb-atlas, azure-ai-search, zilliz) | `rules/rag/vector-managed/<tool>/CLAUDE.md` + `rules/rag/_core/*` |
| Self-hosted vector DB (chroma, milvus, pgvector, qdrant, weaviate) | `rules/rag/vector-selfhosted/<tool>/CLAUDE.md` + `rules/rag/_core/*` |
| Graph DB (neo4j, memgraph, arangodb, neptune, tigergraph) | `rules/rag/graph/<tool>/CLAUDE.md` |
| Doc processing (unstructured, docling, llamaparse, parsers/ocr) | `rules/rag/document-processing/<tool>/CLAUDE.md` |
| Embeddings (api / local) | `rules/rag/embeddings/<api-embeddings|local-embeddings>/CLAUDE.md` |
| Rerankers / search (lexical, neural) | `rules/rag/search-rerank/<tool>/CLAUDE.md` |
| Chunking | `rules/rag/chunking/CLAUDE.md` |
| LLM observability (langsmith, arize-phoenix, monitoring) | `rules/rag/observability/<tool>/CLAUDE.md` |

When RAG rows match, also include the relevant `rules/rag/_core/*` files
(`embedding-security.md`, `vector-store-security.md`, `retrieval-security.md`,
`document-processing-security.md`) as on-demand.

### 4. Propose, then confirm

Present a compact table: **rule path · why it matched (the signal) · activation
(always-on / on-demand)**. Note anything you deliberately skipped and why. Ask
the user to approve, trim, or add. **Do not download until they confirm.**

If the repo already has `.claude/security-rules/SOURCES.md`, read it first and
frame the proposal as a diff (new / unchanged / now-irrelevant) rather than a
fresh install.

### 5. Download the approved set

Pass every approved upstream path to the fetch helper (one invocation):

```sh
printf '%s\n' \
  rules/_core/owasp-2025.md \
  rules/languages/python/CLAUDE.md \
  ... \
  | bash .claude/skills/security-rules-sync/scripts/fetch-rules.sh -
```

It writes each file under `.claude/security-rules/<path minus leading rules/>`
with a provenance header and (re)writes `.claude/security-rules/SOURCES.md`. It
fails safe: a bad fetch leaves any existing copy intact and exits non-zero.

### 6. Wire the always-on core into CLAUDE.md

Edit `.claude/CLAUDE.md` to add — or replace, if already present — a single
managed block. Keep it between markers so re-runs update in place instead of
duplicating:

```markdown
<!-- BEGIN security-rules (managed by security-rules-sync) -->
## Security coding rules

Foundational secure-coding rules are always in effect (imported below). For
stack-specific rules, consult the matching file under `.claude/security-rules/`
whenever you write, review, or refactor code in that area — see
@security-rules/SOURCES.md for the catalog and provenance.

- OWASP Top 10 baseline. See @security-rules/_core/owasp-2025.md
- AI/ML security. See @security-rules/_core/ai-security.md
<!-- (one bullet per downloaded rules/_core/* file, matching what you fetched) -->
<!-- END security-rules (managed by security-rules-sync) -->
```

Only list `@` imports for the `_core` files you actually downloaded. Import
paths are relative to `.claude/`, so `.claude/security-rules/_core/owasp-2025.md`
is written `@security-rules/_core/owasp-2025.md`.

### 7. Report

Summarize what landed: always-on imports added to CLAUDE.md, on-demand files
under `.claude/security-rules/`, and anything skipped. Remind the user these are
third-party MIT rules pinned to a commit, and that re-running the skill refreshes
them. If the repo is git-tracked, suggest reviewing `git diff` before committing.

## Refreshing / updating

Re-running is safe and idempotent: it rewrites `SOURCES.md`, refreshes files, and
replaces the managed CLAUDE.md block. To pull a newer upstream, pass a new commit
SHA to the fetch helper with `--ref <sha>` (find the latest on the repo's default
branch) and update the pin in this skill's scripts if the bump should stick.

## Notes

- **Third-party rules.** These come from an external MIT-licensed repo. Keep the
  provenance headers and `SOURCES.md` so their origin stays clear.
- **Don't hand-edit** downloaded files under `.claude/security-rules/` — the next
  sync overwrites them. Repo-specific overrides belong in `.claude/CLAUDE.md`.
- **Enforcement levels.** Each rule is tagged `strict` / `warning` / `advisory`.
  Treat `strict` as hard constraints and surface `warning`/`advisory` items as
  suggestions when relevant.
- This skill only adds rules; it does not run a security audit. For that, use the
  project's security-review flow after the rules are in place.
