```bash
git clone --depth 1 https://github.com/levontumanyan/home_directory
./install.sh
```

Todo:

- [ ] ownership of the files in this repo (root?)
- [ ] script install zsh, then switches to a zsh shell with all the proper options `set -euox`
- [ ] add history settings
- [ ] why does .zshrc gets overriden after install. update. then git pull sometimes has a merge issue
- [ ] put buckups in one dir...clean up backup files after 3 iterations
- [ ] kubectl completions not working
- [ ] move fzf binary inside `$HOME/bin`
- [ ] cleanup the fzf directory that we download

# backup homedir

```bash
sudo rsync -a --progress --exclude=".local/" --exclude=".vscode-remote/" "$HOME/" "./backup/"
```

# cron command for brew casks and formulas to be backed up
* * * * * /Users/levontumanyan/home_directory/brew_cron.sh >> /tmp/brew_cron.log 2>&1
