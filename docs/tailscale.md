# Tailscale & Taildrop

Tailscale is used in this setup to provide a secure, private mesh network between devices (Work and Personal), enabling seamless file transfers via **Taildrop**.

## Why Tailscale?
- **Cross-Account**: Works even if your Macs use different iCloud accounts.
- **Secure**: End-to-end encryption using WireGuard.
- **Simple**: No firewall configuration or port forwarding required.

## Setup Instructions

1. **Installation**:
   - **Mac**: Included in `brewfile_essentials`.
   - **Mobile (iOS/Android)**: Download "Tailscale" from the App Store or Google Play Store.

2. **Login**:
   - Open the Tailscale app.
   - Click "Log in...".
   - Authenticate using the **same** Tailscale account on all devices (Work Mac, Personal Mac, and Mobile).

## Headless / Cloud Machines

For cloud machines or headless servers, use the CLI to authenticate:

1. **Installation**: Follow the official Tailscale [Linux installation guide](https://tailscale.com/download/linux).
2. **Service Management**:
   - **macOS (Homebrew)**:
     ```bash
     brew services start tailscale
     ```
   - **Linux**:
     ```bash
     systemctl enable --now tailscaled
     ```
3. **Authentication**:
   ```bash
   tailscale up
   ```
   Follow the provided URL to authenticate the machine.

## Fresh Installation & Cleanup

If you need to switch accounts or start from a completely clean state (e.g., clearing the networking stack), follow these steps:

1. **Uninstall & Wipe State**:
   ```bash
   # Logout to clear server-side keys
   tailscale logout

   # Stop and remove the service
   sudo brew services stop tailscale

   # Remove the binary and state files
   sudo rm -rf /opt/homebrew/Cellar/tailscale
   rm -rf ~/.local/share/tailscale
   rm -f ~/Library/Preferences/com.tailscale.ipn.macsys.plist
   ```

2. **Reinstall**:
   ```bash
   brew install tailscale
   ```

3. **Restart as Root Service**:
   On macOS, Tailscale works most reliably when run as a system-wide root service:
   ```bash
   sudo brew services start tailscale
   tailscale up --force-reauth
   ```

4. **Gemini CLI (Trusted Folders)**:
   In headless environments, you must explicitly trust the workspace to avoid interactive prompts. Set this environment variable in your shell profile (`.zshrc` or `.bashrc`):
   ```bash
   export GEMINI_CLI_TRUST_WORKSPACE=true
   ```

## Sending Files (Taildrop)
   - **From Mac**: Click the Tailscale menu bar icon > `Send File...` > Select device.
   - **From Mobile**: Open a file/photo > tap `Share` > select `Tailscale` > select device.
   - **Via CLI**:
     ```bash
     tdrop <file> <destination-hostname>:
     ```

## Security
Tailscale is identity-native. Access is tied to your SSO provider. Data is encrypted and never readable by Tailscale servers.
