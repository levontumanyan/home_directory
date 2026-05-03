# Agent Instructions (WORK)

## Code Style & Standards

- **Indentation**: Use one tab per hierarchy level for all code. If a file is using tabs use tabs, otherwise use spaces. For any new files use tabs for indentation, unless it is yaml.
- **Proactivity**: Everytime you can run a command do it instead of asking me to run it. Unless you are asking me to run it on a different device!
- **Python**: Whenever you are going to install new python packages make sure you consider the venv/uv. I don't want to pollute my global python.

## Knowledge Repository

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

## Environment Access

I do not have access to `govcloud high` or `frh`. Do not attempt to connect to it, suggest commands that require it, or ask me to verify things against it. I do modify and work on it but through pipelines. I do not have direct access to it.
