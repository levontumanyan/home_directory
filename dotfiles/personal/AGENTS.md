# System Instruction

- Assume all standard and user-specified CLI tools (e.g., gh) are installed and available. Do not execute availability or existence checks (e.g., command -v, which, or --version) prior to use. Execute the primary target command directly. Only if it shows that the command isn't there start digging into that.
- Exception Rule: You may query the binary version strictly if the requested operation relies on a flag or feature introduced in a specific release. If a version check is executed, state the required version and the feature dependency.
- If the user asks about a Github issue or pr, always use `gh` cli commands. Do not fetch the website directly. Also every time you mention/create a pr/issue provide the full link to the user.

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

# Personal Repos

All repos live under ~/repos/.

- home_directory: Cross-platform dotfiles and environment bootstrap for macOS and Linux. Uses GNU Stow and Homebrew. Go here for shell config, aliases, Brewfiles, install scripts, and machine profiles.
- knowledge-base: Personal markdown note vault organized by life domain (career, comp_sci, work log, finances, learning, personal, travel, writing). Go here to take notes, log daily work, or do research.
- ragging-my-brain: Local RAG pipeline that embeds knowledge-base notes into a FAISS vector store and answers questions via a local LLM. Stack: Python, FAISS, sentence-transformers. Run with `python main.py`. Go here to work on the retrieval pipeline, chunking, or embedding logic.
- equiquant: Programmatic financial analysis and stock scoring pipeline with a React web dashboard. Stack: Python (uv), SQLite, React/pnpm. Run with `make start`. Go here for scoring models, data providers, or dashboard work.
- cloud-lab: Containerized market data pipeline that pulls stock prices (yfinance) and macro indicators (FRED API) into InfluxDB and visualizes them in Grafana. Stack: Python, Podman Compose. Run with `make up`. Go here for new tickers, indicators, Grafana dashboards, or infra changes.
- inbox-pipeline: Private email automation pipeline. Reads emails, downloads attachments, uploads to Google Drive, and runs Python processing on bank statements. Stack: Python (uv). Go here for email fetching logic, attachment routing rules, Google Drive integration, or bank statement parsing.
