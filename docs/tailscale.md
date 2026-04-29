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

3. **Sending Files (Taildrop)**:
   - **From Mac**: Click the Tailscale menu bar icon > `Send File...` > Select device.
   - **From Mobile**: Open a file/photo > tap `Share` > select `Tailscale` > select device.
   - **Via CLI**:
     ```bash
     tdrop <file> <destination-hostname>:
     ```

## Security
Tailscale is identity-native. Access is tied to your SSO provider. Data is encrypted and never readable by Tailscale servers.
