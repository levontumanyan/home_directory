# System Instruction

- use ripgrep: `rg` for searching/grepping
- make sure in scripts `--help` output is automatically generated
- Assume all standard and user-specified CLI tools (e.g., gh) are installed and available. Do not execute availability or existence checks (e.g., command -v, which, or --version) prior to use. Execute the primary target command directly. Only if it shows that the command isn't there start digging into that.
- Exception Rule: You may query the binary version strictly if the requested operation relies on a flag or feature introduced in a specific release. If a version check is executed, state the required version and the feature dependency.
- If the user asks about a Github issue or pr, always use `gh` cli commands. Do not fetch the website directly. Also every time you mention/create a pr/issue provide the full link to the user.
- Stop executing things when i am just asking you a question. Answer first if i ask you to do something then do it.
- **Calendar & Reminders CLI**: Use `cal-event add "<title>" --start "<YYYY-MM-DD HH:MM>"` for calendar events (defaults to iCloud -> Home) and `cal-event add "<title>" --reminder --due "<YYYY-MM-DD HH:MM>"` for Apple Reminders (integrates directly with Reminders & Calendar; see `cal-event --help`). Reminders should always be created with this script using the `--reminder` flag. When adding items to groceries (`--calendar "Grocery"`), always add each item atomically (one single item per reminder, e.g. separate commands for milk and meat, never combined like 'milk and meat'). Before adding anything to the grocery list, always run `cal-event list --reminder --calendar "Grocery" --all` first to inspect the entire grocery history in one shot, so existing items can be matched and reactivated cleanly without creating duplicates.
- **WhatsApp CLI**: Use `whatsapp chats` (list/recent), `whatsapp read "<contact/phone/username>"` (supports `@username`), `whatsapp documents` (list/search docs & attachments), `whatsapp search "<query>"`, `whatsapp unread`, or `whatsapp draft --to "<contact/phone/username>" --message "<text>"` (see `whatsapp --help`).
- **Outlook CLI**: Reads, searches, and drafts Outlook emails via Microsoft Graph API; see `outlook --help` for options.
- **Yahoo Mail CLI**: Reads, searches, and drafts Yahoo emails via IMAP/SMTP; see `yahoo --help` for options.
- **Apple Pay CLI**: Queries and searches local Apple Pay transactions on macOS; see `apple-pay --help` for options.
- **iMessage CLI**: Queries and searches local iMessage chat history on macOS; see `imessage --help` for options.
- **PDF Text Extraction**: Use `pdftotext` directly to extract and read PDF contents; it is already installed and available. Do not write ad-hoc Python scripts (e.g. `pypdf`) or run tool existence checks.
- **Browser Automation**: Always use the stealth browser MCP (`stealth-browser`) for agent browsing; never launch system browser binaries directly.
- **Google Maps**: Always use Google Maps MCP tools for location and place queries. When suggesting places, always provide their full Google Maps URL.
- **Airbnb**: Use the `airbnb` CLI tool for search, scoring, and listing inspection. Always explicitly report the nightly rate (e.g. CAD $XX/night) whether presenting a single listing or multiple listings.
- **Wi-Fi & Speed CLI**: Use `wifi-check` for Wi-Fi health, speed tests, and VPN audits (use `-q` for quick, `-j` for JSON; see `wifi-check --help`).
- **Git Execution**: Never use `git -C`. Run bare `git` commands directly in the current workspace. For other repositories, use `(cd <path> && git <cmd>)`.
- **Secrets & Passwords**: Never print, echo, or expose raw passwords, tokens, or credentials in chat or command outputs so they never enter agent context.
- **Local Agent Sessions & Memory**: Antigravity maintains an SQLite database of all local conversation history, metadata, and full-text search (`conversations_fts` table) at `~/.gemini/antigravity-cli/conversation_summaries.db` (with raw transcripts and artifacts in `~/.gemini/antigravity-cli/brain/<conversation-id>/`). Be proactive: use this as a research tool to inspect past sessions, check if related work was already done locally, or recall past solutions and commands instead of starting from scratch.

# GitHub Issue & PR Bodies

Always write issue and PR bodies to a temp file first, then pass it via `--body-file`. Never use inline heredocs for `gh issue create` or
`gh pr create` — backticks and nested quotes corrupt the markdown.

# Code Style & Standards

- **Indentation**: Use one tab per hierarchy level for all code. Never use spaces, except for YAML files.
- **Proactivity**: Everytime you can run a command do it instead of asking me to run it. Unless you are asking me to run it on a different device!
- **Python**: Always execute Python commands, scripts, and one-liners via uv (e.g., uv run python ...), never bare python or python3. Whenever installing packages or creating environments, strictly use uv/venv so global python is never polluted.
- **Permissions**: Avoid using `chmod +x` because it grants executable permissions to everyone. Instead, grant the minimum permissions necessary (e.g., `chmod u+x` or specific octal modes like `755`/`700`).
- Use tabs for indentation in all files — shell scripts, Makefiles, config files, etc. The only exception is YAML, which requires spaces by spec.
- In Markdown files, never use ASCII/text-based borders, cards, or custom section headers (e.g. `===` or `---` frames). Use simple standard Markdown headers (`#`, `##`, etc.) instead.

## Knowledge Repository

My personal knowledge base is located at: `~repos/knowledge-base`
- **Bank & Financial Accounts Registry**: `~repos/knowledge-base/finances/accounts.yaml`
- **Personal Details**: `~repos/knowledge-base/personal/profile.md`

## File Naming Conventions

- **Unified Instructions**: If a repository contains `GEMINI.md` or `CLAUDE.md`, unify them into a single `AGENTS.md` file and symlink the original filenames back to it. `AGENTS.md` is the primary source of truth for all AI instructions.

- In Markdown files, always use a single '#' for top-level section headings. Sub-sections should use '##'. Avoid using '###' or deeper unless absolutely necessary. Major sections must always be at the root heading level (#). Avoid having one # top level heading only.

# Personal Repos

All repos live under ~/repos/.

- home_directory: Cross-platform dotfiles and environment bootstrap for macOS and Linux. Uses GNU Stow and Homebrew. Go here for shell config, aliases, Brewfiles, install scripts, and machine profiles.
- knowledge-base: Personal markdown note vault organized by life domain (career, comp_sci, work log, finances, learning, personal, travel, writing). Go here to take notes, log daily work, or do research.
- ragging-my-brain: Local RAG pipeline that embeds knowledge-base notes into a FAISS vector store and answers questions via a local LLM. Stack: Python, FAISS, sentence-transformers. Run with `python main.py`. Go here to work on the retrieval pipeline, chunking, or embedding logic.
- equiquant: Programmatic financial analysis and stock scoring pipeline with a React web dashboard. Stack: Python (uv), SQLite, React/pnpm. Run with `make start`. Go here for scoring models, data providers, or dashboard work.
- cloud-lab: Containerized market data pipeline that pulls stock prices (yfinance) and macro indicators (FRED API) into InfluxDB and visualizes them in Grafana. Stack: Python, Podman Compose. Run with `make up`. Go here for new tickers, indicators, Grafana dashboards, or infra changes.
- shoebox: Private email automation pipeline. Reads emails, downloads attachments, uploads to Google Drive, and runs Python processing on bank statements. Stack: Python (uv). Go here for email fetching logic, attachment routing rules, Google Drive integration, or bank statement parsing.
- games: Collection of self-hosted web games (FastAPI, JavaScript). Deployed to AJ West's hosted server (`levon-box`, accessible via SSH `ssh levon-box` over Cloudflare Tunnel, web domain `https://levon.ajwest.ca/`). Supports multi-project hosting under separate subpaths. Services run via systemd (`/etc/systemd/system/*.service`), reverse proxied by Nginx (`/etc/nginx/levon-apps/*.conf`), and auto-deployed via git post-receive hook to `/home/levon/games/`. Asynchronous agent communication with AJ's AI agent is handled via `relay` on `levon-box`.
