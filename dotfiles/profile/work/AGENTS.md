# Agent Instructions (WORK)

# Code Style & Standards

- **Comments**: Don't overdo comments. If something is important and needs to be documented suggest edits to markdown files. If you are making changes to a file that exists in different environments keep in mind consistency.
- **Indentation**: Use one tab per hierarchy level for all code. If a file is using tabs use tabs, otherwise use spaces. For any new files check conventions. If no conventions in the repo use tabs for indentation, unless it is yaml.
- **Proactivity**: Everytime you can run a command do it instead of asking me to run it. Unless you are asking me to run it on a different device!
- **Python**: Whenever you are going to install new python packages make sure you consider the venv/uv. I don't want to pollute my global python.
- **Permissions**: Avoid using `chmod +x` because it grants executable permissions to everyone. Instead, grant the minimum permissions necessary (e.g., `chmod u+x` or specific octal modes like `755`/`700`).

# github

- Anytime you create/update an issue, create/update a pr. Give the full link at the end of your response! For example: `https://github.com/elastic/platform-security-team/issues/1280`
- **PR and issue references**: Whenever you mention a PR or GitHub issue by number, always format it as a markdown hyperlink so it is clickable. For example: [PR #2407](https://github.com/elastic/platform-security-terraform/pull/2407) or [issue #901](https://github.com/elastic/platform-security-team/issues/901). Never reference a number alone without a link.
- Always run `gh pr update-branch <PR_NUMBER> && gh pr comment <PR_NUMBER> --body "buildkite plan this"` — never trigger a plan without updating first in the same command. Also run that after everytime you commit new changes to a pr. If it reports conflicts, resolve them via rebase before proceeding.
- Always write issue and PR bodies to a temp file first, then pass it via `--body-file`. Never use inline heredocs for `gh issue create` or `gh pr create` — backticks and nested quotes corrupt the markdown.

# tools

- When you need to check buildkite pipeline, use bk commands. For example, `bk build view 11641 --pipeline elastic/platform-security-terraform`. No need to check `bk` is already in the path. If you need api token run `bk configure --org elastic`.
- I am using `podman`! No `docker`.
- For `buildkite`, `bk` stuff use the MCP.

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

When creating PSEC issues, always add them to this project. Use the `/github-cli` skill for full Sprint/iteration management workflows and GraphQL mutation patterns.

## PSEC Does NOT Use Jira

Use `gh issue` commands instead. The Atlassian MCP tools are still valid for non-PSEC Jira projects and Confluence.

# Knowledge Repository

My personal knowledge base is located at: `~repos/knowledge-base`

When I ask you to "document this", "create a doc for this issue", or "create a file with the branch name", do the following:
1. Get the current branch name: `git branch --show-current`
2. Use that as the filename (e.g., `feat/PROJ-123-add-auth` → `PROJ-123-add-auth.md`)
3. Create a new markdown file in `~repos/knowledge-base/elastic/`
4. Populate it with:
   - Branch name / issue reference
   - Current repo and path
   - What the issue/feature is about (ask me if unclear)
   - Key decisions or notes
5. When I ask you to create a subissue i want you to use:

# Environment Access

I do not have access to `govcloud high` or `frh`. The changes there are some done through pipelines and ECK helm/kubectl commands are run manually by my US based coworkers. So from my workstation it is not possible to access things that are behind the FRH vpn. FRS/FRM i do have full access, through VPN the things that are gated behind a VPN.

# File Naming Conventions

- **Unified Instructions**: If a repository contains `GEMINI.md` or `CLAUDE.md`, unify them into a single `AGENTS.md` file and symlink the original filenames back to it. `AGENTS.md` is the primary source of truth for all AI instructions.

- **Markdown headings**: Personal docs use multiple `#` for top-level sections. Team repos (`elastic/platform-security-team`, `elastic/platform-security-terraform`) follow the single H1 standard: one `#` title, `##` for sections.
