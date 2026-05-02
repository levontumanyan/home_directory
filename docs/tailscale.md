# Tailscale & Taildrop

Tailscale is used in this setup to provide a secure, private mesh network between devices, enabling seamless file transfers via **Taildrop**.

## Why Tailscale?
- **Cross-Account**: Works even if your devices use different iCloud/SSO accounts.
- **Secure**: End-to-end encryption using WireGuard.
- **Simple**: No firewall configuration or port forwarding required.

## My Network (MagicDNS Names)
- **`personal`**: macOS (Personal MacBook Air)
- **`work`**: macOS (Work MacBook Pro)
- **`fibonacci`**: Linux (Cloud Machine)

## Setup Instructions

### 1. Installation
- **macOS**: Installed automatically via `install.sh` (Homebrew).
- **Linux**: Installed automatically via `install.sh` (Official Native Script).
  - *Note: We avoid Homebrew on Linux for Tailscale because the Homebrew formula often lacks the necessary `systemd` unit files.*
- **Mobile (iOS/Android)**: Download "Tailscale" from the App Store or Google Play Store.

### 2. Service Management
Tailscale requires a background daemon (`tailscaled`) to be running.

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

## Sending Files (Taildrop)

### Using Aliases
The following aliases are defined in `.aliases.zsh`:
- `tsend`: Sends files (`tailscale file cp`)
- `tget`: Receives files (`tailscale file get`)

**Examples:**
```bash
# Send a file to the cloud machine
tsend my_photo.jpg fibonacci:

# Receive files on the current machine
tget .
```

### Agent Usage (For Gemini/Claude)
For AI agents to use these aliases, they must run commands in an **interactive Zsh shell**:
```bash
zsh -ic "tdrop <file> <destination>:"
```

## Fresh Installation & Cleanup

If you need to switch accounts or start from a completely clean state, follow these steps:

1. **Logout & Wipe State**:
```bash
tailscale logout
sudo brew services stop tailscale  # macOS
sudo systemctl stop tailscaled     # Linux
sudo rm -rf /var/lib/tailscale     # Linux state
rm -rf ~/.local/share/tailscale    # macOS state
```

2. **Reinstall**:
Re-run `./install.sh`.

## Security
Tailscale is identity-native. Access is tied to your SSO provider. Data is end-to-end encrypted and never readable by Tailscale servers.
