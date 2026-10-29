# Agent Instructions

# Code Style & Standards

- **Comments**: Don't overdo comments. If something is important and needs to be documented suggest edits to markdown files. If you are making changes to a file that exists in different environments keep in mind consistency. If you are working on a pr prefer adding comments/info into the pr body instead of using comments in the file. Stop overusing hashtag comments(for example in .tf files)
- **Indentation**: Use one tab per hierarchy level for all code. If a file is using tabs use tabs, otherwise use spaces. For any new files check conventions. If no conventions in the repo use tabs for indentation, unless it is yaml.
- **Proactivity**: Everytime you can run a command do it instead of asking me to run it. Unless you are asking me to run it on a different device!
- **Python**: Whenever you are going to install new python packages make sure you consider the venv/uv. I don't want to pollute my global python.
- **Permissions**: Avoid using `chmod +x` because it grants executable permissions to everyone. Instead, grant the minimum permissions necessary (e.g., `chmod u+x`).
- When you mention some work, do not say we completed this pr. Say I worked on this pr...
- Always refer to yourself in first person singular ("I," "my") when describing anything you did, are doing, or are proposing. Never use "we" to mean "you and I".

# github

- Anytime you create/update an issue, create/update a pr. Give the full link at the end of your response! For example: `https://github.com/elastic/platform-security-team/issues/1280`
- If i mention number of points for an issue add it! Otherwise skip that part but mention in your summary that the issue has no points.
- in pst repo when making any changes use the worktree skill unless i mention to just make the changes in the main wortkree
- **PR and issue references**: Whenever you mention a PR or GitHub issue by number, always format it as a markdown hyperlink so it is clickable. For example: [PR #2407](https://github.com/elastic/platform-security-terraform/pull/2407) or [issue #901](https://github.com/elastic/platform-security-team/issues/901). Never reference a number alone without a link.
- Always run `gh pr update-branch <PR_NUMBER> && gh pr comment <PR_NUMBER> --body "buildkite plan this"` — never trigger a plan without updating first in the same command. Also run that after everytime you commit new changes to a pr. If it reports conflicts, resolve them via rebase before proceeding.
- Always write issue and PR bodies to a temp file first, then pass it via `--body-file`. Never use inline heredocs for `gh issue create` or `gh pr create` — backticks and nested quotes corrupt the markdown. Also use `--body-file` for `gh pr comment` whenever the body contains code blocks or backticks.
- When you are working on a PR, especially when closing it make sure that the PR is closing an issue. If there is no issue that related that is fine, but it doesn't hurt to ask the user if you cannot deduce the issue that the PR should close to confirm if there is an issue or not.
- When creating a PR that resolves an issue, use a GitHub-recognized closing keyword (Closes/Resolves/Fixes) with the full cross-repo reference (e.g., Closes elastic/platform-security-team#2191) as the first line of the PR body. Do not use Part of — it's informational only and won't populate the issue's Development panel or auto-close on merge.

# tools

- `sessions` indexes local Claude Code, OpenCode, Codex, and Pi sessions; use its MCP for historical context, and use `sessions context`, `sessions --here`, or `sessions why <file>` from the CLI.
- Documentation: `https://github.com/nicknisi/sessions`; local command reference: `sessions --help`.

- if you are creating a terraform file that needs to be generated with harp-terraformer always do that. And make sure the specs exist and generate the file from the specs. Never manually create those files.
- For `buildkite`, `bk` stuff use the MCP.
- When you need to check buildkite pipeline, if the mcp didn't work. use bk commands. For example, `bk build view 11641 --pipeline elastic/platform-security-terraform`. No need to check `bk` is already in the path. If you need api token run `bk configure --org elastic`.
- After running `buildkite apply this` if there are resources to apply the pipiline will be blocked, waiting for manual approval at the apply step. I will need you to pull the plan output to verify what it's proposing and tell me if all are good to apply or not. And if there are any resources that need to be applied/modified/deleted that are not from our changes flag immediately!
- I am using `podman`! No `docker`.

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

## PSEC Does NOT Use Jira

Use `gh issue` commands instead. The Atlassian MCP tools are still valid for non-PSEC Jira projects and Confluence.

# Knowledge Repository

My personal knowledge base is located at: `~repos/knowledge-base`. Elastic stuff goes under `~repos/knowledge-base/elastic`

# AWS/Kubernetes Authentication

For AWS access, use `platform-cli-auth`. In every Bash tool call, source and invoke the helper in the same shell: `source "$HOME/.local/share/platform-cli-auth/aws-config/mfa" && mfa-frm`. Never inspect `~/.okta` directly or invoke raw `okta-aws-cli`.

# github

When asked to create subissues, always create distinct child issue objects instead of adding comments or text mentions to the parent. Ensure a strict database-level hierarchy by explicitly passing the parent ID in the creation mutation.
Always create prs in non draft, even if some other instructions tell you otherwise.

# Environment Access

I do not have access to `govcloud high` or `frh`. The changes there are some done through pipelines and ECK helm/kubectl commands are run manually by my US based coworkers. So from my workstation it is not possible to access things that are behind the FRH vpn. FRS/FRM i do have full access, through VPN the things that are gated behind a VPN. (all envs are behind a VPN).

## AWS CLI Profile Naming

There are **two separate profile systems** — do not confuse them

**1. Okta profiles** (in `~/.okta/okta.yaml`, used by `mfa-*` aliases and `okta-aws-cli`):

Alias|Okta profile, `mfa`|`commercial`, `mfa-frm`|`govcloud-frm`, `mfa-frs`|`govcloud-frs`, `mfa-frh`|`govcloud-frh`

**2. AWS CLI workspace profiles**

| Env | `--profile` for security ops | `--profile` for ecsecurity IAM |
|-----|------------------------------|--------------------------------|
| Commercial | `ecsecurity` | `ecsecurity` |
| FRM | `gov-frm-uge1-security` | `gov-frm-uge1-ecsecurity` |
| FRS | `gov-stg-uge1-security` | `gov-stg-uge1-ecsecurity` |
| FRH | `gov-frh-uge1-security` | `gov-frh-uge1-ecsecurity` |

for FRS is `gov-stg-uge1-security` is the correct profile.

**What is `ecsecurity`?** The IAM security bastion account in each org — holds cross-account audit roles and PSEC-owned security automation. For general AWS API calls (e.g. checking EBS encryption, querying EC2), use the `*-security` profile. The `*-ecsecurity` profile is for IAM/SAML role management in Terraform.

**Region**: all GovCloud envs use `us-gov-east-1`.

# File Naming Conventions

- **Unified Instructions**: If a repository contains `GEMINI.md` or `CLAUDE.md`, unify them into a single `AGENTS.md` file and symlink the original filenames back to it. `AGENTS.md` is the primary source of truth for all AI instructions.

- **Markdown headings**: Personal docs use multiple `#` for top-level sections. Team repos (`elastic/platform-security-team`, `elastic/platform-security-terraform`) follow the single H1 standard: one `#` title, `##` for sections.

# kubectl

- logging: When it makes sense suggest `k logs -f statefulsets/<name>` instead of directly logging a pod.

# slack

Use these channel IDs directly with Slack MCP tools — do not spend a turn searching for them.

- `#platform-security-eng` (`C09F3MZQM9S`) - my team's engineering channel. When i ask you to post in psec channel for review it is here
- `#platform-security` (`C64AY13FF`) - my team's channel where we get requests from users
- :platform-security-eng: to post to #platform-security-eng with Reacji Channeler
- **Always draft first, no exceptions.** When i ask you to draft a message it means use the slack mcp to draft a message. Don't output the text in the code session. Never directly send a message unless i explicitly request. Always draft a message then i will send it. This applies even when i ask you to review something or "check" something — do NOT infer that as permission to send. The ONLY time you may send a message directly is if i say "send this" or "post this" or explicitly ask you to send it. If in doubt, draft. Never ever send a slack message without confirming with me first.

- When making technical decisions, do not give much weight to development cost. Instead, prefer quality, simplicity, robustness, scalability, and long term maintainability.
- When explaining technical concepts write or rewrite text in plain, layman-readable English in the spirit of ASD-STE100 Simplified Technical English: short sentences, active voice, simple tenses, one word one meaning, condition before command, every technical term defined at first use, no AI slop. Default mode is Plain. Strict mode applies full STE vocabulary compliance when the user names STE, ASD-STE100, or compliance. Use for documentation, READMEs, runbooks, procedures, error messages, release notes, incident reports, API guides. Also use when the user says "STE", "Simplified Technical English", "ASD-STE100", "plain English", "layman's terms", "explain it simply", "no jargon", "de-slop", "make this readable", "write for non-native readers", or asks for docs that translate well. The same rules govern the reply: answer first, prose only.
- when you have to decide what version of a package/tool to use do a live search and consider using the latest stable versions. Never use outdated versions or make assumptions without doing a live search
