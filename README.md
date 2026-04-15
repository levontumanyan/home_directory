```bash
git clone --depth 1 https://github.com/levontumanyan/home_directory
./install.sh
```

Manually make sure that iterm looks at this dir for its settings: `/Users/levontumanyan/home_directory/dotfiles/iterm`

# proposed fixes

Proposed fixes

2. setup_envs.sh: Remove the broken BACKUP_FILES (already covered by the explicit loop in install.sh)
3. install.sh: Save the backup path to ~/.dotfiles_last_backup after backing up
4. uninstall.sh: Read ~/.dotfiles_last_backup to find the correct backup dir to restore from

Todo:

- [ ] create `.claude/settings.json`
  - `gh issue view*` safe to run
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
