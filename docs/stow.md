# GNU Stow in this Repo

[GNU Stow](https://www.gnu.org/software/stow/) is a symlink farm manager. It takes distinct packages of software and/or data located in separate directories and makes them appear to be installed in the same place.

## How it's used here

This repository uses Stow to manage dotfiles by symlinking them from the `dotfiles/` directory into your `$HOME` directory.

### Directory Structure

The `dotfiles/` directory is organized into "packages":

```text
dotfiles/
├── base/          # Files installed on ALL machines
│   ├── .zshrc
│   ├── .aliases.zsh
│   └── .config/
│       └── tmux/
└── work/          # Files installed only on WORK machines
    └── .work.zsh
```

### The Stow Command

The `install.sh` script runs stow like this:

```bash
stow --dir="path/to/repo/dotfiles" --target="$HOME" --restow base
```

- `--dir`: The source directory containing the packages.
- `--target`: Where the symlinks should be created (usually your home directory).
- `--restow`: Tells stow to prune obsolete symlinks and then install again. This is useful for updating existing links.
- `base`: The name of the package directory inside `dotfiles/` to install.

### How Symlinking Works

Stow mirrors the internal structure of the package directory into the target directory.

**Example:**
If you have:
`~/repos/home_directory/dotfiles/base/.config/tmux/tmux.conf`

Stow will create a symlink at:
`~/.config/tmux/tmux.conf` -> `~/repos/home_directory/dotfiles/base/.config/tmux/tmux.conf`

#### Folder vs File Symlinking
- If the destination folder (e.g., `~/.config/tmux`) does not exist, Stow might symlink the **folder** itself.
- If the destination folder already exists as a real directory, Stow will reach inside and symlink the **individual files**.

## Precautions

1. **Conflicts:** If a "real" file (not a symlink) already exists where Stow wants to create a link, Stow will error out. The `install.sh` script handles this by moving conflicting files to a backup directory first.
2. **Empty Directories:** Stow does not manage empty directories by default.
3. **Recursive Stow:** Our `install.sh` handles base and work packages separately to allow for machine-specific configurations.

## Maintenance

To manually refresh your symlinks after adding new files to the repo:
```bash
# Refresh base dotfiles
stow -d ~/repos/home_directory/dotfiles -t ~ -R base
```

## The Symlink Paradox (Double-Hops)

When managing "intelligent" dotfiles (like `GEMINI.md` or `CLAUDE.md` pointing to a global `AGENTS.md`), we must be careful with relative symlinks.

### The Problem
If you have a symlink in the repo `base` folder pointing to a file in the `personal` folder, Stow will create a link in your Home directory that points into the Repo. However, once you are inside the repo via that link, any **relative** jumps (like `../AGENTS.md`) are resolved relative to the **Repo's** physical location, not your **Home** directory.

### The Solution
Relative symlinks must be co-located in the same Stow "package" as their target.

- **Correct**: `dotfiles/personal/.config/gemini/GEMINI.md` -> `../../AGENTS.md` (where `AGENTS.md` is at `dotfiles/personal/AGENTS.md`).
- **Incorrect**: `dotfiles/base/.config/gemini/GEMINI.md` -> `../../AGENTS.md` (this would look for `dotfiles/base/AGENTS.md`, which doesn't exist).

This is why profile-specific agent instructions are mirrored across `personal` and `work` packages instead of sitting in `base`.
