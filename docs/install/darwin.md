# Setup Darwin

## Setup

### Install Base Tools

```bash
# Command-line tools
xcode-select --install

# Rosetta
sudo softwareupdate --install-rosetta

# Nix
sh <(curl -L https://nixos.org/nix/install)
```

### Install Bootstrap Keys

- Clone <https://github.com/gustavclausen/nix-secrets.git>
- Run:

  ```bash
  ./scripts/decrypt-age-key.sh
  ./scripts/sync-bootstrap-keys.sh
  ```

### Github Personal Access Token For Bootstrap

Set Github Personal Access Token when bootstrapping the host for the first time:

```bash
export NIX_CONFIG="access-tokens = github.com=ghp_..."
```

## Install

```bash
nix develop
just switch <HOSTNAME>
```
