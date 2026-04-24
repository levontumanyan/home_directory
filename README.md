```bash
git clone --depth 1 https://github.com/levontumanyan/home_directory
./install.sh
```

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

Manually make sure that iterm looks at this dir for its settings: `/Users/levontumanyan/home_directory/dotfiles/iterm`

# stow reorg

Migrate symlink management from the custom `find` + `ln` loop in `install.sh` to GNU Stow. This fixes the broken uninstall, handles nested directories (iterm) cleanly, and makes the work/personal split explicit as separate packages.

## Steps

### 1. Install stow

Add `stow` to both Brewfiles so it is available on all machines.

```sh
# brewfile_work and brewfile_personal
brew "stow"
```

### 2. Restructure `dotfiles/` into stow packages

Stow requires each package to be a subdirectory whose contents mirror the layout under `$HOME`. Rename and reorganize:

```
dotfiles/
  base/           # installed on all machines
    .aliases.zsh
    .completions.zsh
    .env.zsh
    .ps1.zsh
    .zshrc
    .config/
      iterm/      # was dotfiles/iterm/
  work/           # installed on work machines only
    work.zsh
```

Note: files that are currently sourced from `$HOME` without a leading dot (`aliases.zsh`, etc.) need to be verified — either they stay without dots or `.zshrc` references are updated to match.

### 3. Update `install.sh`

Replace the `find` + `ln` loop and the `work.zsh` special-case with stow calls:

```sh
stow --dir="$DOTFILES_DIR/dotfiles" --target="$HOME" base
[ "$MACHINE_TYPE" = "work" ] && stow --dir="$DOTFILES_DIR/dotfiles" --target="$HOME" work
```

Remove the backup loop that guards against stow overwriting real files — stow will refuse to overwrite non-symlink files and error out, which is safer than silently moving things.

### 4. Update `uninstall.sh`

Replace the broken manual symlink removal with:

```sh
stow --dir="$DOTFILES_DIR/dotfiles" --target="$HOME" -D base
[ "$MACHINE_TYPE" = "work" ] && stow --dir="$DOTFILES_DIR/dotfiles" --target="$HOME" -D work
```

### 5. Verify iterm path

After restructure, update the iterm manual step in this README. iTerm2 will need to point at the new path inside `dotfiles/base/.config/iterm/` (or wherever it lands after restructure).

### 6. Test on a clean machine / VM

Run `install.sh`, confirm symlinks land correctly, then run `uninstall.sh` and confirm all symlinks are removed without touching real files.

---

# proposed fixes

Proposed fixes

2. setup_envs.sh: Remove the broken BACKUP_FILES (already covered by the explicit loop in install.sh)
3. install.sh: Save the backup path to ~/.dotfiles_last_backup after backing up
4. uninstall.sh: Read ~/.dotfiles_last_backup to find the correct backup dir to restore from

Todo:

- use stow for the symlink management.
- move k8s functions to it's own thing. Follow Stick convention for this!
- `sesh.toml` `tmux.conf` should be added to dotfiles.
- [ ] bring the alt tab settings/tmux/sesh.toml
- [ ] create `.claude/settings.json`
  - `gh issue view*` safe to run
- [ ] add an install brew script for linux as well.
```bash
==> Next steps:
- Run these commands in your terminal to add Homebrew to your PATH:
    echo >> /home/ubuntu/.zshrc
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"' >> /home/ubuntu/.zshrc
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"
- Install Homebrew's dependencies if you have sudo access:
    sudo apt-get install build-essential
  For more information, see:
    https://docs.brew.sh/Homebrew-on-Linux
- We recommend that you install GCC:
    brew install gcc
- Run brew help to get started
- Further documentation:
    https://docs.brew.sh
```
- [ ] idempotency is kinda broken
- [ ] better separation of work packages to install vs personal machine stuff. and common maybe?
- [ ] fzf everything - what does that even mean. not just history?
- [ ] proper backups and restores
- [ ] restoring from backups is broken
- [ ] remove the bin dir
- [ ] kubectl binary is only linux(arm/x86-64) compatible. add mac/darwin support.
- [ ] ownership of the files in this repo (root?)
- [ ] add history settings
- [ ] put buckups in one dir...clean up backup files after 3 iterations
- [ ] automate brew stuff, like upgrade, update, cleanups.

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
