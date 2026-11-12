# System Instructions

- **Tool Execution & Checks**: Assume all standard and personal CLI tools are installed and available. Do not run existence checks (`which`, `command -v`, `--version`) prior to execution; run the target command directly. Exception: you may query a binary version strictly if the requested operation relies on a flag or feature introduced in a specific release (state the required version and dependency).
- **Proactivity vs. Questions**: If asked a direct or conceptual question, answer first without executing commands. For operational tasks, code modifications, or troubleshooting, execute commands proactively instead of asking for permission (unless the command must be run on a different physical device).
- **Search & Scripts**: Use ripgrep (`rg`) for searching and grepping. Ensure all authored scripts automatically generate `--help` output.
- **Git Execution**: Never use `git -C`. Run bare `git` commands directly in the current workspace. For other repositories, use `(cd <path> && git <cmd>)`.
- **Secrets & Passwords**: Never print, echo, pass, embed, or expose raw passwords, tokens, API keys, or credentials anywhere in chat, command-line arguments, scripts, heredocs, or command outputs so they never enter agent context. Secrets must strictly remain in local config/environment files (e.g. `~/.config/...`) and be accessed only via environment variables or file reads.
- **Agent Memory**: Antigravity maintains an SQLite database of all local conversation history and full-text search at `~/.gemini/antigravity-cli/conversation_summaries.db` (with raw transcripts and artifacts in `~/.gemini/antigravity-cli/brain/<conversation-id>/`). Query this database proactively to inspect past sessions, check if related work was already done locally, or recall past solutions and commands instead of starting from scratch.

# Tool Integrations

- **GitHub CLI (`gh`)**: Always use `gh` CLI commands for GitHub issues and PRs (never fetch the website directly). Always include full PR/issue links in responses. Always write issue and PR bodies to a temporary file first and pass via `--body-file` (never use inline heredocs for `gh issue create` or `gh pr create` as backticks and quotes corrupt markdown).
- **Personal CLI Tools**: Custom automation tools live in `~/repos/agent-tools` (`bin/` on PATH): `cal-event` (Calendar/Reminders/Groceries), `whatsapp`, `imessage`, `outlook`, `yahoo`, `apple-pay`, `wifi-check`, `airbnb`, `call-recordings`, `download-video`, and `portfolio`. See `~/repos/agent-tools/AGENTS.md` or `<tool> --help` for subcommands and options.
- **Browser Automation**: Always use the stealth browser MCP (`stealth-browser`) for agent browsing; never launch system browser binaries directly.
- **Google Maps**: Always use Google Maps MCP tools for location and place queries. When suggesting places, always provide their full Google Maps URL.
- **PDF Text Extraction**: Use `pdftotext` directly to extract and read PDF contents; it is already installed and available. Do not write ad-hoc Python scripts (e.g. `pypdf`).

# Code Style & Conventions

- **Indentation**: Use one tab per hierarchy level for all code, shell scripts, Makefiles, and config files. Never use spaces, except for YAML files which require spaces by specification.
- **Python**: Always execute Python commands, scripts, and one-liners via `uv` (e.g. `uv run python ...`), never bare `python` or `python3`. Whenever installing packages or creating environments, strictly use `uv`/venv so global python is never polluted.
- **Permissions**: Avoid using `chmod +x` because it grants executable permissions to everyone. Instead, grant minimum permissions necessary (e.g. `chmod u+x` or specific octal modes like `755`/`700`).
- **Markdown Headers & Style**: Use standard Markdown headers (`#`, `##`). Never use ASCII/text-based borders, cards, or custom section frames (e.g. `===` or `---` frames). Major sections must always use top-level `#` headings (avoid having only a single top-level `#` heading). Subsections use `##`. Avoid using `###` or deeper unless strictly necessary.
- **Unified Instructions**: If a repository contains `GEMINI.md` or `CLAUDE.md`, unify them into a single `AGENTS.md` file and symlink the original filenames back to it. `AGENTS.md` is the primary source of truth for all AI instructions.

# Repository Index

All personal repositories reside under `~/repos/`. Detailed architectures, dependencies, and operational commands are documented in each repo's local `AGENTS.md`.

- **`knowledge-base`**: Personal markdown knowledge vault organized by life domain (`career`, `comp_sci`, `finances`, `learning`, `personal`, `travel`, `work log`).
	- Accounts Registry: `~/repos/knowledge-base/finances/accounts.yaml`
	- Profile Details: `~/repos/knowledge-base/personal/profile.md`
- **`home_directory`**: Cross-platform dotfiles, shell configs, stow profiles, and machine bootstrap.
- **`agent-tools`**: Swift, Python, and Shell CLI tool suite providing system, communication, and personal automation binaries (`bin/`).
- **`games`**: Self-hosted web games and workout tracker (FastAPI + JS, hosted on `levon-box`).
- **`equiquant`**: Financial analysis and stock scoring pipeline with React web dashboard (Python uv, SQLite).
- **`cloud-lab`**: Market data pipeline with yfinance, FRED API, InfluxDB, and Grafana (Podman Compose).
- **`shoebox`**: Automated email bank statement downloader, PDF parser, and Google Drive backup (Python uv, SQLite).
- **`ragging-my-brain`**: Local RAG pipeline embedding knowledge-base notes into FAISS vector store.
