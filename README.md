```bash
git clone --depth 1 https://github.com/levontumanyan/home_directory
./install.sh
```

# Testing

Test `install.sh` in a clean Linux environment using the devcontainer image (requires [Podman](https://podman.io)):

```bash
podman run --rm -it \
  -v ~/repos/home_directory:/workspaces/home_directory:z \
  --userns=keep-id \
  -w /workspaces/home_directory \
  --user vscode \
  localhost/vsc-home_directory-c7ce67ba2cdfe6685c27895981ace7f05c4c12f2d1b273be9ca98862dc2f0087:latest \
  zsh
```

`--rm` destroys the container on exit so each run starts from a clean slate. Once inside:

```bash
./install.sh
```

To rebuild the image after changing `.devcontainer/Dockerfile` or `.devcontainer/devcontainer.json`, use VS Code: `Cmd+Shift+P` → **Dev Containers: Rebuild Container**.

# Keeping Brewfiles updated

After installing new packages on a machine, snapshot the current state back into the repo so other machines stay in sync.

**Work machine:**
```sh
brew bundle dump --force --file=brewfile_work
```

**Personal machine:**
```sh
brew bundle dump --force --file=brewfile_personal
```

Then commit and push. The dump overwrites the file with everything currently installed via Homebrew — formulas, casks, taps, and VS Code extensions.

> Note: `brew bundle dump` outputs everything flat. Casks and macOS-only formulas will be included without any Linux guards — that's expected, the Brewfiles are macOS-first.

Manually make sure that iterm looks at this dir for its settings: `~/.config/iterm`

# Symlink management (stow)

Symlinks are managed with [GNU Stow](https://www.gnu.org/software/stow/). Stow mirrors a package directory tree into a target (`$HOME`), creating one symlink per file. It errors out rather than silently overwriting real files, and `-D` cleanly reverses everything.

## Package structure

```
dotfiles/
  base/       # stowed on all machines
  work/       # stowed on work machines only
```

Each package mirrors the layout of `$HOME`. For example:
- `dotfiles/base/.zshrc` → `~/.zshrc`
- `dotfiles/base/.config/iterm/com.googlecode.iterm2.plist` → `~/.config/iterm/com.googlecode.iterm2.plist`
- `dotfiles/work/.work.zsh` → `~/.work.zsh`

## Adding a new dotfile

1. Create the file at the mirrored path inside `dotfiles/base/`:
   - `~/.tmux.conf` → `dotfiles/base/.tmux.conf`
   - `~/.config/foo/bar.conf` → `dotfiles/base/.config/foo/bar.conf`
2. Re-run `install.sh`, or restow manually:
   ```sh
   stow --dir="$DOTFILES_DIR/dotfiles" --target="$HOME" --restow base
   ```
3. Commit and push.

For work-only files, use `dotfiles/work/` instead.

## Removing a dotfile

1. Delete the file from `dotfiles/base/` (or `dotfiles/work/`).
2. Restow to clean up the orphaned symlink:
   ```sh
   stow --dir="$DOTFILES_DIR/dotfiles" --target="$HOME" --restow base
   ```
3. Commit and push.

---

# proposed fixes

Proposed fixes

2. setup_envs.sh: Remove the broken BACKUP_FILES (already covered by the explicit loop in install.sh)
3. install.sh: Save the backup path to ~/.dotfiles_last_backup after backing up
4. uninstall.sh: Read ~/.dotfiles_last_backup to find the correct backup dir to restore from

Todo:

- [x] make sure there is an option to run the script completely uninteractively for testing/debugging
- [ ] restoring from backups is broken
- move k8s functions to it's own thing. Follow Stick convention for this!
- [ ] bring the alt tab settings/tmux/sesh.toml
- [ ] create `.claude/settings.json`
  - `gh issue view*` safe to run
- [ ] idempotency is kinda broken
- [ ] fzf everything - what does that even mean. not just history?
- [ ] ownership of the files in this repo (root?)
- [ ] add history settings
- [ ] put buckups in one dir...clean up backup files after 3 iterations
- [x] automate brew stuff, like upgrade, update, cleanups.
- [x] make sure that we can control things like gemini/claude in sesh. with an env variable possibly? coming from a dotfile
- [x] better ps1(include git branching, and kubecontext)

# backup homedir

```bash
sudo rsync -a --progress --exclude=".local/" --exclude=".vscode-remote/" "$HOME/" "./backup/"
```

# cron command for brew casks and formulas to be backed up
* * * * * /Users/levontumanyan/home_directory/brew_cron.sh >> /tmp/brew_cron.log 2>&1

# info

Macos install stuff requires sudo!

`Homebrew not found, installing...` - after this line you will need your sudo password to install brew!

# git config setup for commit signing

```bash
git config --global user.signingkey <YOUR_SIGNING_SUBKEY_ID>
git config --global commit.gpgsign true
git config --global tag.gpgsign true
```
