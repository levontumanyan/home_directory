# Agent Instructions

# Code Style & Standards

- **Comments**: Code is only code. Context, design rationale, history, and references go in the PR body. Start every file I write or edit with zero comments; add a single inline comment only where a line's meaning is invisible on its own (e.g. a version-pinned ID that breaks on upgrade), max 2 lines. This holds even when neighboring files in the target repo carry long header blocks — local style yields to this rule. Before pushing, review every comment line in the diff and move each one that is not a non-obvious invariant into the PR body.
- **Indentation**: One tab per hierarchy level. Match the file's existing convention (tabs or spaces); for new files with no convention, use tabs — except yaml and markdown, which use spaces. In markdown, tab-indented list items do not render (a tab is 4 spaces; lists allow at most 3), so indent lists with spaces; fenced code blocks follow the fenced language's convention.
- **Proactivity**: Everytime you can run a command do it instead of asking me to run it. Unless you are asking me to run it on a different device!
- **Python**: When installing python packages use a venv/uv. Never pollute my global python.
- **Permissions**: Avoid `chmod +x` — it grants executable permissions to everyone. Use the minimum necessary (e.g. `chmod u+x`, or `755`/`700`).
- Always refer to yourself in first person singular ("I," "my") when describing anything you did, are doing, or are proposing. Never use "we" to mean "you and I" — say "I worked on this PR", not "we completed this PR".

# Fresh Repository State

Checkouts in `~/repos` sit idle for weeks and often rest on old feature branches, so treat every local checkout as stale by default.

- At the start of any change, `git fetch` the canonical remote. Canonical remote per layout: `origin` where `origin` is `elastic/*`; for `~/repos/cloud` it is `upstream` (there, `origin` is my fork and carries no upstream state). Fetch updates remote-tracking refs only — local branches and files stay untouched.
- Create the worktree or branch from the fetched default branch (`upstream/master` for `cloud`, `origin/main` elsewhere), and confirm freshness with `git rev-list --count <base>..<remote>/<default>` reporting `0` behind before reading code for design decisions.
- Treat a fact read from an unfetched checkout as a hypothesis: it enters a report, PR body, or commit only after it is confirmed against the fetched default branch — including facts relayed by reviewers, teammates, or sibling workers.

# GitHub

- Anytime you create/update an issue or PR, give the full link at the end of your response (e.g. `https://github.com/elastic/platform-security-team/issues/1280`). Always format PR/issue references as markdown hyperlinks — never a number alone.
- If i mention story points for an issue, add them.
- In pst repo when making any changes use the worktree skill, unless i mention to just make the changes in the main worktree.
- When asked to create subissues, create distinct child issue objects — explicitly pass the parent ID in the creation mutation. Never use comments or text mentions on the parent.
- Always create PRs as non-draft, even if some other instructions tell you otherwise.
- Some PRs merge happily without an issue — small fixes, doc tweaks, and routine changes are perfect standalone PRs. When a PR does resolve an issue, open the body with a closing keyword and the full cross-repo reference (e.g. `Closes elastic/platform-security-team#2191`) so GitHub auto-links it. If a PR has no linked issue, drop its link somewhere in your response and remind me to give it story points.
- Always write issue and PR bodies to a temp file first, then pass it via `--body-file`. Never use inline heredocs for `gh issue create` or `gh pr create` — backticks and nested quotes corrupt the markdown. Also use `--body-file` for `gh pr comment` whenever the body contains code blocks or backticks.

# Buildkite (elastic/platform-security-terraform)

- Every push to a PR builds and plans automatically. Never comment `buildkite plan this` or `buildkite build this` — they do nothing now. For a fresh plan, push to the branch (a rebase onto main counts). If `gh pr update-branch` reports conflicts, resolve them via rebase.
- Plans run on every push, so read the existing plan comment. If something needs applying, run `gh pr update-branch <PR_NUMBER>` and tell me it is ready — **I** comment `buildkite apply this`. Never post that comment yourself, and never answer, approve or unblock an approval gate; that is my decision as the token holder.
- After I comment `buildkite apply this`, the apply build blocks at a per-workspace approval gate. Identify the build's PR from its `pull-request-identity` annotation or `GITHUB_PR_NUMBER` env — never from its branch, commit or title, which are `main`'s. Pull the plan output and tell me if all is good to apply; flag immediately any resource to be applied/modified/deleted that is not part of my PR's changes.
- In dstg/dil5 buildkite cannot apply anything — run local terraform applies instead. Always post a PR comment containing the validated local plan and what was applied.
- Before any local `terraform plan` or `apply`, `git fetch origin main` and fast-forward/rebase the worktree onto `origin/main` (worktrees go stale silently). Never plan from a stale checkout — it shows phantom drift for changes already applied live.
- For `buildkite`/`bk` stuff use the MCP; if it didn't work, fall back to `bk` commands — `bk` is already in the path. For example: `bk build view 11641 --pipeline elastic/platform-security-terraform`. If you need an api token: `bk configure --org elastic`.
- Terraform files covered by harp-terraformer specs must be generated from the specs — never create them by hand. If the specs don't exist, say so before writing anything manually.

# tools

- `sessions` indexes local Claude Code, OpenCode, Codex, and Pi sessions; use its MCP for historical context, and use `sessions context`, `sessions --here`, or `sessions why <file>` from the CLI. Documentation: `https://github.com/nicknisi/sessions`; local command reference: `sessions --help`.
- I am using `podman`! No `docker`.
- **Search**: use `rg`, not `grep`, in shell commands for content search — `rg` skips `.terraform`, hidden, and gitignored files by default, while `grep -r` scans them and burns minutes on big checkouts. `grep` is fine only as a pipe stage (`ls | grep`). No `\|` BRE escapes with `rg` — plain `|` alternation.

## Vault CLI

**Always use `vault_select` to authenticate to Vault. Never use raw `vault login`.**

Each bash call is a fresh process — env vars don't persist across calls. `vault_select` checks `envchain` (macOS keychain) for a cached token first and only triggers the OIDC browser flow when the token is actually expired. Raw `vault login` bypasses this caching and re-authenticates every time.

Pattern for any Vault command — all in one bash call:

```bash
source ~/repos/platform-cli-auth/vault-helper/vault-helper.sh && vault_select <cluster> && vault kv get secret/foo
```

Common cluster aliases: `infra-prod` (secrets.elastic.co), `infra-staging` (vault-acc.elastic.co), `cloud-gov` (GovCloud moderate), `dod-dstg` (DSTG), `dod-dil5` (DIL5). Run `vault_select` with no args for the full interactive list.

## VPN Switching (AWS Client VPN only)

`aws-vpn-client` controls AWS Client VPN (FRS/FRH/DSTG/DIL5). Aviatrix (Commercial, FRM) is GUI-only; only my user connects or disconnects it. Aviatrix = `platform`, `frm`, `global-it` in `vpn-helper` output. Two full tunnels cannot run at the same time — Aviatrix drops AWS-bound packets with no error. If `detect` returns Aviatrix, stop and ask my user to disconnect first.

LLM access per tunnel: Commercial, `frm` — all providers; `dstg`, `dil5` — all providers (for now); `frs`, `frh` — AWS Bedrock only (for now). My user has no `frh` access — do not try.

```bash
helper=~/repos/platform-cli-auth/vpn-helper/vpn-helper.sh
bash "$helper" detect                                  # Aviatrix result → stop
aws-vpn-client disconnect --profile-name <current>     # only an AWS tunnel
aws-vpn-client connect --profile-name <target>
bash "$helper" validate <target>                      # must exit 0 before Vault or Teleport
```

- If `detect` returns `none`, skip the disconnect.
- `connect` may open a browser for Okta SAML; user completes it. Wait for `Connected` from `get-connection-status`.

Actual `aws-vpn-client` profile names (use these for `--profile-name`, NOT the cluster aliases):

| Target | vpn-helper target | `aws-vpn-client` profile |
|--------|-------------------|--------------------------|
| FRS | `frs` | `frs` |
| FRH | `frh` | `frh` (no access) |
| DSTG | `dstg` | `dstg` |
| DIL5 | `dil5` | `il5` |
| DIL5 staging | `dil5` | `il5_staging` |

`validate` takes the vpn-helper target (`dil5`/`dstg`/...), not the profile name. The Vault cluster aliases for `vault_select` are `dod-dstg` and `dod-dil5`.

## MCP Priority Order (Elastic questions)

When answering Elastic-related questions, check sources in this order:

1. `elastic-team-internal-docs` — internal processes, runbooks, team knowledge (codex.elastic.dev)
2. `elastic-docs` — public product docs, API reference, feature docs (elastic.co/docs)
3. Web search — blogs, announcements, anything not covered above

# PSEC GitHub Project Board

The **only** relevant GitHub Project for PSEC work is [Platform Security Team (#2289)](https://github.com/orgs/elastic/projects/2289).

| Item | Value |
|------|-------|
| Project number | 2289 |
| Project node ID | `PVT_kwDOAGc3Zs4BSCW-` |
| Sprint field ID | `PVTIF_lADOAGc3Zs4BSCW-zg_sDTE` |
| Story Points field ID | `PVTF_lADOAGc3Zs4BSCW-zg_sDTA` |
| Status field ID | `PVTSSF_lADOAGc3Zs4BSCW-zg_sCpA` |

- When creating PSEC issues, always add them to this project
- When creating GitHub issues in elastic/platform-security-team, always assign a sprint: Incoming Requests for backlog, else the active sprint — never leave the Sprint field unset
- Sprint iteration IDs rotate; never hardcode them. List live ones: `gh api graphql -f query='query{node(id:"PVT_kwDOAGc3Zs4BSCW-"){... on ProjectV2{field(name:"Sprint"){... on ProjectV2IterationField{configuration{iterations{id title}}}}}}' --jq '.data.node.field.configuration.iterations[] | .id + "  " + .title'`
- If `gh project item-edit` fails on Sprint ("Did not receive an iteration Id"), use a raw mutation: `gh api graphql -f query='mutation{updateProjectV2ItemFieldValue(input:{projectId:"PVT_kwDOAGc3Zs4BSCW-",itemId:"<item>",fieldId:"PVTIF_lADOAGc3Zs4BSCW-zg_sDTE",value:{iterationId:"<id>"}}){projectV2Item{id}}}'`

PSEC does NOT use Jira — use `gh issue` commands instead. The Atlassian MCP tools are still valid for non-PSEC Jira projects and Confluence.

# Code Reviews & Verification

- **Verify, don't infer.** Any claim that can be checked with a command or file read gets checked. Tool output is the source of truth, not memory or inference. An empty grep is not evidence of absence — corroborate with a second method. A passing `plan`/`--dry-run` is not proof the real operation works. If I don't know, I say so; no guessing or fabricating.
- **PR reviews**: lead with a 2-3 sentence summary of what the PR does, then inline line-specific comments. Read the body text of every review and comment — an APPROVED review often carries nits. Check auto-merge and CODEOWNERS before choosing approve vs. comment. Don't report what the author can already see (their CI, their conflicts), and don't flag unrelated plan drift.
- **Severity**: a finding whose mechanism I traced in code is fact. A missing corroboration (silent subagent, green test) never justifies a downgrade — only new evidence that refutes the mechanism does. Never round "didn't check" down to "probably fine".
- **Self-review**: before pushing my own PR, review the full `git diff <base>...HEAD` as someone else's PR. Fix the class, not the flagged instance — grep the changed identifier/invariant across the repo and fix every occurrence in the same commit. Reason one step past the edit: what depended on what I just removed or renamed?
- **Briefing review subagents**: name the area, never the direction the bug would take — a stated direction excludes its opposite. Keep at least one reviewer unbriefed, given only the diff.

# Knowledge Repository

My personal knowledge base is located at: `~repos/knowledge-base`. Elastic stuff goes under `~repos/knowledge-base/elastic`

# AWS/Kubernetes Authentication

For AWS access, use `platform-cli-auth`. In every Bash tool call, source and invoke the helper in the same shell: `source "$HOME/.local/share/platform-cli-auth/aws-config/mfa" && mfa-frm`. Never inspect `~/.okta` directly or invoke raw `okta-aws-cli`.

**DIL5 auth**: `source "$HOME/.local/share/platform-cli-auth/aws-config/mfa" && mfa-dil5` — Okta SAML lands in `604555006356` (ecsecurity). Profiles: ops = `dod-dil5-uge1-security`, bastion/state = `dod-dil5-uge1-ecsecurity`. The DIL5 terraform state bucket lives in ecsecurity, and its resource policy denies every `secops` role except ones assumed in `604555006356` — so terraform init/apply must always use the `*-ecsecurity` profile as backend (the workspace `.envrc` sets this via `TF_CLI_ARGS_init`; skipping `.envrc` fails init with an S3 explicit deny that looks like an IAM bug). Never use `dod-dil5-*-public` profiles locally — `source_profile = dod-dil5-public` does not exist on this machine, and `TROUBLESHOOTING.md`'s claim that they bridge via `commercial` is stale. Never assume `role/cross_account/buildkite-secops` — it is locally assumable in ecsecurity and can write/delete CI state. Before local dstg/dil5 applies, check nothing else holds the state lock (`use_lockfile = true`).

# Environment Access

I do not have access to `govcloud high` or `frh`. FRH changes are done through pipelines, and ECK helm/kubectl commands there are run manually by my US-based coworkers — nothing behind the FRH VPN is reachable from my workstation. I have full access to FRS/FRM through VPN. All envs are behind a VPN.

## AWS CLI Profile Naming

There are **two separate profile systems** — do not confuse them.

**1. Okta profiles** (in `~/.okta/okta.yaml`, used by `mfa-*` aliases and `okta-aws-cli`):

| Okta profile | `mfa` alias |
|--------------|-------------|
| `commercial` | `mfa` |
| `govcloud-frm` | `mfa-frm` |
| `govcloud-frs` | `mfa-frs` |
| `govcloud-frh` | `mfa-frh` |
| `dod-dil5` | `mfa-dil5` |
| `dod-dstg` | `mfa-dstg` |

**2. AWS CLI workspace profiles** (Commercial uses `ecsecurity` for both):

| Env | `--profile` for security ops | `--profile` for ecsecurity IAM |
|-----|------------------------------|--------------------------------|
| FRM | `gov-frm-uge1-security` | `gov-frm-uge1-ecsecurity` |
| FRS | `gov-stg-uge1-security` | `gov-stg-uge1-ecsecurity` |
| FRH | `gov-frh-uge1-security` | `gov-frh-uge1-ecsecurity` |
| DIL5 | `dod-dil5-uge1-security` | `dod-dil5-uge1-ecsecurity` |
| DSTG | `dod-dstg-uge1-security` | `dod-dstg-uge1-ecsecurity` |

**What is `ecsecurity`?** The IAM security bastion account in each org — holds cross-account audit roles and PSEC-owned security automation. For general AWS API calls (e.g. checking EBS encryption, querying EC2), use the `*-security` profile. The `*-ecsecurity` profile is for IAM/SAML role management in Terraform.

**Region**: all GovCloud envs use `us-gov-east-1`.

# File Naming Conventions

- **Unified Instructions**: If a repository contains `GEMINI.md` or `CLAUDE.md`, unify them into a single `AGENTS.md` file and symlink the original filenames back to it. `AGENTS.md` is the primary source of truth for all AI instructions.
- **Markdown headings**: Personal docs use multiple `#` for top-level sections. Team repos (`elastic/platform-security-team`, `elastic/platform-security-terraform`) follow the single H1 standard: one `#` title, `##` for sections.

# kubectl

- Logging: when it makes sense, suggest `k logs -f statefulsets/<name>` instead of directly logging a pod.

# Slack

Use these channel IDs directly with Slack MCP tools — do not spend a turn searching for them.

- `#platform-security-eng` (`C09F3MZQM9S`) - my team's engineering channel. When i ask you to post in psec channel for review it is here
- `#platform-security` (`C64AY13FF`) - my team's channel where we get requests from users
- :platform-security-eng: to post to #platform-security-eng with Reacji Channeler
- **GitHub links in Slack**: always inline descriptive links (e.g. `<https://github.com/elastic/gov-ecp-gitops/pull/3823|gov-ecp-gitops#3823>`), never a bare URL or a number alone.
- **Never send a Slack message unless I explicitly say "send this" or "post this".** Default to drafting via the Slack MCP instead of outputting the text in the session — this applies even to "review" or "check" requests. If in doubt, draft.
- Slack drafts:

  - First line: the point or ask. Context after, only if needed.
  - After the first time I draft a message, do not assume it is still sitting in drafts — in later turns, check the channel to see if it was already sent before referring to it as a pending draft.
  - Max 1-4 short sentences. One topic per message.
  - For asks, name who, what, by when.
  - Plain words, active voice. No filler, hedging, or sign-offs.
  - 3+ parallel items: bullets. Links last, labeled.
  - No headers or emoji. Bold only one key item.

# General

- When making technical decisions, do not give much weight to development cost. Instead, prefer quality, simplicity, robustness, scalability, and long term maintainability.
- When explaining technical concepts write or rewrite text in plain, layman-readable English in the spirit of ASD-STE100 Simplified Technical English: short sentences, active voice, simple tenses, one word one meaning, condition before command, every technical term defined at first use, no AI slop. Default mode is Plain; full STE vocabulary compliance applies only when the user names STE, ASD-STE100, or compliance. Use for documentation, READMEs, runbooks, procedures, error messages, release notes, incident reports, API guides, and replies (answer first, prose only). Triggers include: "STE", "Simplified Technical English", "ASD-STE100", "plain English", "layman's terms", "explain it simply", "no jargon", "de-slop", "make this readable", "write for non-native readers", or a request for docs that translate well.
- When you have to decide what version of a package/tool to use, do a live search and use the latest stable version. Never use outdated versions or make assumptions without a live search.
