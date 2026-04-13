```bash
git clone --depth 1 https://github.com/levontumanyan/home_directory
./install.sh
```

Manually make sure that iterm looks at this dir for its settings: `/Users/levontumanyan/home_directory/dotfiles/iterm`

Todo:

- [ ] fix the zoxide bug. (right now we only install it in macos, but source it in general. on a linux machine this errors out).
- [ ] fzf everything - what does that even mean. not just history?
- [ ] proper backups and restores
- [ ] separate brew lists for work/personal
- [ ] restoring from backups is broken
- [ ] remove the bin dir
- [ ] kubectl binary is only linux(arm/x86-64) compatible. add mac/darwin support.
- [ ] ownership of the files in this repo (root?)
- [ ] add history settings
- [ ] why does .zshrc gets overriden after install. update. then git pull sometimes has a merge issue
- [ ] put buckups in one dir...clean up backup files after 3 iterations
- [ ] kubectl completions not working
- [ ] ssh key setup for cron to be able to run the cron script daily
- [ ] uninstall not removing the .zshrc link

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
