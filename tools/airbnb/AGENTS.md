# Code Standards

- **Indentation**: Use **Tabs** exclusively for all code.
- **Exception**: Use **Spaces (2 or 4)** only for YAML if required by the specification.
- **Formatting**: Always run `make format` and `make lint` before finishing any task to ensure compliance with the project's Ruff configuration.

# Environment & Execution

- **Command Policy**: **ALWAYS** use `make` commands for all operations (running, testing, linting).
- **Prohibited**: Do **NOT** run or suggest direct `uv` or `python3` command calls.

# Testing & Validation

- **Test Suite**: Use `make test` to validate changes.

# Currency & Domain Standards

- **Primary Currency**: **ALWAYS** evaluate, search, and report Airbnb prices in **CAD** unless the user explicitly requests otherwise.
- **Listing URLs**: **ALWAYS** format Airbnb listing URLs using the Canadian domain: `https://www.airbnb.ca/rooms/<id>`. Never use `airbnb.com`.

# Development Workflow Mandates

After every major code change, the following steps MUST be performed in order:
1. **Format:** Run `make format` to ensure code style compliance.
2. **Test:** Run `make test` to ensure no regressions were introduced.
3. **Stage:** Stage all relevant changes.
4. **Commit:** Provide a detailed commit message and execute the commit.

Do not propose or perform a commit until formatting and testing have passed successfully.
