# Tailscale & Taildrop

Tailscale is used in this setup to provide a secure, private mesh network between devices, enabling seamless file transfers via **Taildrop**.

## Why Tailscale?
- **Cross-Account**: Works even if your devices use different iCloud/SSO accounts.
- **Secure**: End-to-end encryption using WireGuard.
- **Simple**: No firewall configuration or port forwarding required.

## Setup Instructions

### 1. Installation
- **macOS**: Installed automatically via `install.sh` (Homebrew).
- **Linux**: Installed automatically via `install.sh` (Official Native Script). 
- **Mobile (iOS/Android)**: Download "Tailscale" from the App Store or Google Play Store.

### 2. Service Management
Tailscale requires a background daemon (`tailscaled`) to be running. This is handled automatically by the setup scripts, but can be managed manually:

- **macOS (Homebrew)**:
  ```bash
  sudo brew services start tailscale
  ```
- **Linux (Native)**:
  ```bash
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

   # 2. Stop and remove the service
   # macOS:
   sudo brew services stop tailscale
   # Linux:
   sudo systemctl stop tailscaled
   sudo systemctl disable tailscaled

   # 3. Remove local state
   # macOS:
   rm -rf ~/.local/share/tailscale
   rm -f ~/Library/Preferences/com.tailscale.ipn.macsys.plist
   # Linux:
   sudo rm -rf /var/lib/tailscale
   ```

2. **Reinstall & Re-auth**:
   Re-run the installation scripts to get a fresh copy:
   ```bash
   ./install.sh
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
