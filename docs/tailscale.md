# Tailscale & Taildrop

Tailscale is used in this setup to provide a secure, private mesh network between devices, enabling seamless file transfers via **Taildrop**.

## Why Tailscale?
- **Cross-Account**: Works even if your devices use different iCloud/SSO accounts.
- **Secure**: End-to-end encryption using WireGuard.
- **Simple**: No firewall configuration or port forwarding required.

## Setup Instructions

### 1. Installation
- **macOS**: Included in `brewfile_essentials`. Runs as a system-wide service.
- **Linux (Homebrew)**: Included in `brewfile_essentials`. Note: Requires manual service linking (see below).
- **Linux (Native - Recommended)**: If Homebrew integration fails, use the official script:
  ```bash
  curl -fsSL https://tailscale.com/install.sh | sh
  ```
- **Mobile (iOS/Android)**: Download "Tailscale" from the App Store or Google Play Store.

### 2. Service Management
Tailscale requires a background daemon (`tailscaled`) to be running.

#### macOS (Homebrew)
```bash
sudo brew services start tailscale
```

#### Linux (Homebrew Integration)
Homebrew on Linux does not automatically register systemd units. If `systemctl status tailscaled` fails, run:
```bash
# 1. Link the service file
sudo ln -s $(brew --prefix)/opt/tailscale/lib/systemd/system/tailscaled.service /lib/systemd/system/tailscaled.service

# 2. Reload and start
sudo systemctl daemon-reload
sudo systemctl enable --now tailscaled
```

### 3. Authentication
Log in to your Tailscale account to join the private network.

- **macOS (CLI)**:
  ```bash
  tailscale up
  ```
- **Linux (Headless)**:
  Use the `--operator` flag to allow running future Tailscale commands without `sudo`:
  ```bash
  sudo tailscale up --operator=$USER
  ```
- **macOS (GUI)**:
  Open the Tailscale app from Applications, click the menu bar icon, and select **Log in...**.
- **Mobile**:
  Open the app and authenticate using the same account as your other devices.

## Fresh Installation & Cleanup

If you need to switch accounts or start from a completely clean state (clearing the networking stack and local keys), follow these steps:

1. **Logout & Wipe State**:
   ```bash
   # 1. Clear server-side keys
   tailscale logout

   # 2. Stop the service
   # macOS:
   sudo brew services stop tailscale
   # Linux:
   sudo systemctl stop tailscaled

   # 3. Remove binary and local state
   # macOS (Homebrew):
   sudo rm -rf /opt/homebrew/Cellar/tailscale
   rm -rf ~/.local/share/tailscale
   rm -f ~/Library/Preferences/com.tailscale.ipn.macsys.plist
   ```

2. **Reinstall & Re-auth**:
   ```bash
   # Reinstall
   brew install tailscale

   # Start service and authenticate fresh
   sudo brew services start tailscale
   tailscale up --force-reauth
   ```

## Gemini CLI Integration

In headless environments, you must explicitly trust the workspace to avoid interactive prompts. Add this to your shell profile (`.zshrc` or `.bashrc`):

```bash
export GEMINI_CLI_TRUST_WORKSPACE=true
```

## Sending Files (Taildrop)
- **From Mac (GUI)**: Click the Tailscale menu bar icon > `Send File...` > Select device.
- **From Mobile**: Open a file/photo > tap `Share` > select `Tailscale` > select device.
- **Via CLI**:
  ```bash
  tailscale file cp <file> <destination-hostname>:
  ```

## Security
Tailscale is identity-native. Access is tied to your SSO provider. Data is end-to-end encrypted and never readable by Tailscale servers.
