# Agent Instructions (WORK)

# Code Style & Standards

- **Comments**: Don't overdo comments. If something is important and needs to be documented suggest edits to markdown files. If you are making changes to a file that exists in different environments keep in mind consistency.
- **Indentation**: Use one tab per hierarchy level for all code. If a file is using tabs use tabs, otherwise use spaces. For any new files check conventions. If no conventions in the repo use tabs for indentation, unless it is yaml.
- **Proactivity**: Everytime you can run a command do it instead of asking me to run it. Unless you are asking me to run it on a different device!
- **Python**: Whenever you are going to install new python packages make sure you consider the venv/uv. I don't want to pollute my global python.

# github

- Anytime you create/update an issue, create/update a pr. Give the full link at the end of your response! For example: `https://github.com/elastic/platform-security-team/issues/1280`
- **PR and issue references**: Whenever you mention a PR or GitHub issue by number, always format it as a markdown hyperlink so it is clickable. For example: [PR #2407](https://github.com/elastic/platform-security-terraform/pull/2407) or [issue #901](https://github.com/elastic/platform-security-team/issues/901). Never reference a number alone without a link.
- Before triggering any buildkite plan or apply, always run `gh pr update-branch <PR_NUMBER>` to merge main into the branch. Also run that after everytime you commit new changes to a pr. If it reports conflicts, resolve them via rebase before proceeding.

# tools

- When you need to check buildkite pipeline, use bk commands. For example, `bk build view 11641 --pipeline elastic/platform-security-terraform`. No need to check `bk` is already in the path. If you need api token run `bk configure --org elastic`.

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

I do not have access to `govcloud high` or `frh`. Do not attempt to connect to it, suggest commands that require it, or ask me to verify things against it. I do modify and work on it but through pipelines. I do not have direct access to it.

# File Naming Conventions

- **Unified Instructions**: If a repository contains `GEMINI.md` or `CLAUDE.md`, unify them into a single `AGENTS.md` file and symlink the original filenames back to it. `AGENTS.md` is the primary source of truth for all AI instructions.

- In Markdown files, always use a single '#' for top-level section headings. Sub-sections should use '##'. Avoid using '###' or deeper unless absolutely necessary. Major sections must always be at the root heading level (#). Avoid having one # top level heading only.
