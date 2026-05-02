# Global Claude Instructions

- whenever possible run the command yourself. instead of giving the user a list of commands. If there are several commands in a row execute them one by one.

## Code style

Use tabs for indentation in all files. The only exception is YAML, which requires spaces by spec. Never use spaces for indentation elsewhere.

## Issue creation

Unless mentioned otherwise, always create issues in: `https://github.com/elastic/platform-security-team`

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

I do not have access to `<env-name>` (e.g., production, staging). Do not attempt to connect to it, suggest commands that require it, or ask me to verify things against it.
