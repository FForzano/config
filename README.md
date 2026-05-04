# config

Personal configuration files and dotfiles for macOS.

## Installation

```bash
git clone <repo-url> ~/path/to/config
cd ~/path/to/config
./install.sh
```

The installer walks through each component interactively, checks if it is already configured, and skips it automatically if so.

### Prerequisites

- [`jq`](https://stedolan.github.io/jq/) — `brew install jq`
- A `secrets.json` file in the repo root (see [Secrets](#secrets) below)

## Components

| ID | Description | OS |
|----|-------------|----|
| `zsh` | Zsh shell config + Powerlevel10k theme | macOS, Linux |
| `ghostty` | Ghostty terminal emulator | macOS |
| `hammerspoon` | Window management and hotkeys | macOS |
| `ssh` | SSH client config + private hosts | macOS, Linux |
| `mc` | Midnight Commander config + mashdark theme | macOS, Linux |
| `lima` | Docker-enabled Linux VM via Lima | macOS |
| `launchagents` | Bitwarden SSH agent LaunchAgent | macOS |

## Secrets

Some components require private values (e.g. SSH server addresses) that are not tracked in git. These are stored in `secrets.json` at the repo root, which is gitignored.

Copy the example and fill in your values:

```bash
cp secrets.example.json secrets.json
```

`secrets.json` is stored in Bitwarden as a secure note. Retrieve it from there when setting up a new machine.

### Schema

```json
{
  "ssh_hosts": [
    {
      "alias": "my-server",
      "hostname": "192.168.1.100",
      "user": "myuser"
    }
  ]
}
```

Each entry in `ssh_hosts` generates a `Host` block in `~/.ssh/config.private`, which is included by the main SSH config.

## Adding a new component

1. Add a block to `install.json` under `components`:

```json
{
  "id": "mytool",
  "name": "My Tool",
  "description": "Short description",
  "os": ["macos"],
  "actions": [
    { "type": "link", "src": "Mac/mytool/config", "dst": "~/.config/mytool/config" }
  ]
}
```

2. Run `./install.sh` — only the new component will be proposed.

### Action types

| Type | Description |
|------|-------------|
| `link` | Creates a symlink; backs up existing file automatically |
| `mkdir` | Creates a directory, optionally with a specific `mode` |
| `shell` | Runs a shell command; add a `check` field to enable idempotency |
| `generate` | Renders a template for each item in a `secrets.json` array |

### Adding a private SSH host

Add an entry to `ssh_hosts` in `secrets.json` and re-run `./install.sh`:

```json
{
  "alias": "prod",
  "hostname": "203.0.113.10",
  "user": "deploy"
}
```

Update the copy stored in Bitwarden afterwards.
