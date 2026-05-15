# nix-config

My Nix configuration for my Darwin and NixOS machines.

## Usage

### Setup

See [docs](./docs/install/) for instructions on how to install new machines.

### Common Commands

See [Justfile](./Justfile) for common commands.

- Deploy configuration on current machine:

  ```shell
  just switch "<HOSTNAME>"
  ```

- Rollback configuration on current machine:

  ```shell
  just rollback "<HOSTNAME>"
  ```

- Deploy remote host:

  ```shell
  just deploy "<HOSTNAME>"
  ```

- Update Flakes:

  ```shell
  just update
  ```

## Inspiration

Based on the following configs:

- [dustinlyons](https://github.com/dustinlyons/nixos-config)
- [Ryan4Yin](https://github.com/ryan4yin/nix-config)

Thanks for the inspiration.
