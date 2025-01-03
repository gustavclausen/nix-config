# nix-config

Based on the following configs:

- [dustinlyons](https://github.com/dustinlyons/nixos-config)
- [Ryan4Yin](https://github.com/ryan4yin/nix-config)

Thanks for the inspiration.

## Overview

My Nix configuration for macOS/Darwin (nix-darwin + home-manager).

## Usage

### Setup

#### OS-Specific

<details>
  <summary>macOS/Darwin</summary>
  
  1. Install base tools

```shell
# Command-line tools
xcode-select --install

# Rosetta
sudo softwareupdate --install-rosetta

# Nix
sh <(curl -L https://nixos.org/nix/install)

# Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Just
brew install just
```

</details>

#### Common

1. Add system to [`flake.nix`](./flake.nix).

2. Secrets setup:

   1. Download
      [gustavclausen/nix-secrets](https://github.com/gustavclausen/nix-secrets)
      to local machine.

   2. Follow instructions for setting up bootstrap secrets.

3. Add GitHub Personal Access token to Nix config (default locations per OS
   documented [here](https://nix.dev/manual/nix/2.22/command-ref/conf-file)):

   ```nix
   access-tokens = github.com=<PAT>
   ```

### Commands

See [Justfile](./Justfile) for common commands.

- Deploy new configuration:

  ```shell
  just switch "<system config name>"
  ```

- Rollback configuration:

  ```shell
  just rollback "<system config name>"
  ```

- Update Flakes:

  ```shell
  just update
  ```
