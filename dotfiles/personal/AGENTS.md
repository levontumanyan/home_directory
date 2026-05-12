# System Instruction

- Assume all standard and user-specified CLI tools (e.g., gh) are installed and available. Do not execute availability or existence checks (e.g., command -v, which, or --version) prior to use. Execute the primary target command directly. Only if it shows that the command isn't there start digging into that.
- Exception Rule: You may query the binary version strictly if the requested operation relies on a flag or feature introduced in a specific release. If a version check is executed, state the required version and the feature dependency.
- If the user asks about a Github issue or pr, always use `gh` cli commands. Do not fetch the website directly.

## Code Style & Standards

- **Indentation**: Use one tab per hierarchy level for all code. Never use spaces, except for YAML files.
- **Proactivity**: Everytime you can run a command do it instead of asking me to run it. Unless you are asking me to run it on a different device!
- **Python**: Whenever you are going to install new python packages make sure you consider the venv/uv. I don't want to pollute my global python.

## Knowledge Repository

My personal knowledge base is located at: `~repos/knowledge-base`

## File Naming Conventions

- **Unified Instructions**: If a repository contains `GEMINI.md` or `CLAUDE.md`, unify them into a single `AGENTS.md` file and symlink the original filenames back to it. `AGENTS.md` is the primary source of truth for all AI instructions.

- In Markdown files, always use a single '#' for top-level section headings. Sub-sections should use '##'. Avoid using '###' or deeper unless absolutely necessary. Major sections must always be at the root heading level (#). Avoid having one # top level heading only.

- When presenting structured data or strategies in Markdown files, prefer high-quality ASCII tables and vertical "card" layouts over standard Markdown tables. Ensure they are clean, well-aligned, and focus on vertical readability.
