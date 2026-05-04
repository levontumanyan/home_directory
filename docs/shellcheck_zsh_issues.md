# ShellCheck Zsh Issues Tracking

This document tracks ShellCheck issues found in Zsh dotfiles and their resolution status. Since ShellCheck does not natively support Zsh, we use `shell=bash` with specific ignores for Zsh-only syntax.

## Currently Identified Issues

| Category | SC ID | Description | Example / Location | Status |
|----------|-------|-------------|--------------------|--------|
| **Zsh Syntax** | SC1087 | Array expansion `[idx]` without braces | `%{$fg_bold[cyan]%}` in `.ps1.zsh` | Fixed (Added `${}`) |
| **Zsh Syntax** | SC2016 | Expressions in single quotes | `PROMPT='...${_git_ps1}'` in `.ps1.zsh` | Ignored (Zsh `PROMPT_SUBST`) |
| **Zsh Globals** | SC2154 | Variable referenced but not assigned | `fg_bold`, `reset_color` (from `colors`) | Ignored (Zsh inherited) |
| **Zsh Globals** | SC2034 | Variable appears unused | `PROMPT`, `SAVEHIST`, `DOCKER_HOST` | Ignored (Zsh internals) |
| **Sourcing** | SC1090/1 | Can't follow non-constant source | `source <(kubectl completion zsh)` | Ignored (Dynamic sourcing) |
| **Sourcing** | SC1091 | Not following external source | `source "$HOME/.env.zsh"` | Ignored (Expected for dotfiles) |
| **Portability** | SC2086 | Double quote to prevent globbing | `kubectl logs deployments/$1` | Fixed (Quoted) |
| **Portability** | SC2207 | Prefer mapfile or read -a | `deployments=($(kubectl ...))` | Ignored (Zsh array syntax) |

## Recommended Directive for Zsh files

Until native Zsh support is available, use:
```bash
# shellcheck shell=bash
```

## Common Ignores for Zsh
- `SC1087`: Zsh allows `[idx]` for associative arrays without `${}`, but adding `${}` is safer and satisfies ShellCheck.
- `SC2154`: Zsh often inherits variables from `autoload` or other sourced files.
- `SC2034`: Variables like `PROMPT` are used by Zsh internally.
