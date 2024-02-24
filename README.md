# nix-config

Based on [dustinlyons' config](https://github.com/dustinlyons/nixos-config).
Thanks for the inspiration.

## Usage

### New System

1. Required for Darwin systems:

   1. Install base tools

      ```shell
      # Command-line tools
      xcode-select --install

      # Nix
      sh <(curl -L https://nixos.org/nix/install)

      # Homebrew
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      ```

2. Add system to [`flake.nix`](./flake.nix).
3. Secrets setup:
   1. Download
      [gustavclausen/nix-secrets](https://github.com/gustavclausen/nix-secrets)
      to local machine.
   2. Follow instructions for setting up bootstrap secrets.
4. Deploy configuration:
   ```shell
   FLAKENAME="<system config name>" make build
   FLAKENAME="<system config name>" make switch
   ```
