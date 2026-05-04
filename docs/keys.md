# GPG + YubiKey Setup

## What caused the signing failure (May 2026)

A `brew upgrade gnupg` upgraded GnuPG to 2.5.x, which reset `~/.gnupg/pubring.kbx`
to an empty file (32-byte header only). GnuPG 2.5 stores public keys in a new
keyboxd backend (`~/.gnupg/public-keys.d/pubring.db`), but only uses it when
`use-keyboxd` is set in `common.conf`. Without that, GPG reads the empty legacy
kbx and finds no keys — even though the YubiKey is connected and `gpg --card-status`
works fine.

Symptoms:
- `gpg --list-keys` returns nothing
- `git commit` fails with `gpg: skipped "...": No secret key`
- Same error in VSCode: `Git: gpg failed to sign the data`

## Fix

`dotfiles/base/.gnupg/common.conf` contains:

```
use-keyboxd
```

This tells GPG to use the keyboxd database where the public keys actually live.
After `install.sh` runs, `~/.gnupg/common.conf` is a symlink to this file, so
the setting persists across GPG upgrades.

## VSCode signing failures

VSCode's git integration fails GPG signing when pinentry can't prompt for a
passphrase or touch confirmation. `dotfiles/base/.gnupg/gpg-agent.conf` sets:

```
pinentry-program /opt/homebrew/bin/pinentry-mac
```

This makes GPG use a native macOS dialog instead of a terminal prompt, which
works from VSCode, background processes, and any non-TTY context.

## YubiKey touch policy

The signing subkey has `UIF: Sign=on` (touch required, cached). When rebasing
many commits, git will time out waiting for a touch on each one. Prefer
`git pull --no-rebase` (merge) over `git pull --rebase` to avoid needing
multiple touches.

## Recovery steps if this happens again

1. Check if the YubiKey is detected: `gpg --card-status`
2. Check if keys are visible: `gpg --list-keys`
3. If empty, check if `~/.gnupg/common.conf` exists and contains `use-keyboxd`
4. If the file is missing, re-run `install.sh -t` or manually:
   ```sh
   echo "use-keyboxd" > ~/.gnupg/common.conf
   gpg --list-keys
   ```
