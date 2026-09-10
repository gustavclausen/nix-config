# nix-config

Personal nix-darwin + NixOS flake.

## Commands

- `just switch` — build and activate the current machine's config. Auto-detects the host from `/etc/current-nix-host` (written by a previous switch); first switch on a machine needs `just switch <hostname>`, e.g. `just switch personal-macbook-pro-m5`. Always confirm with user that host is correct before running `just switch <hostname>`.
- `just build [host]` — build without activating (same host inference). Always confirm with user that host is correct before running command.
- `just deploy <host>` — push a NixOS host's config over SSH via `deploy-rs`, for a remote host you aren't switching locally.
- `just rollback <host>` — interactive generation rollback (asks for a generation number). Always confirm with user that host is correct before running `just switch <hostname>`.
- Never run `darwin-rebuild` / `nixos-rebuild` / `deploy-rs` directly — always through `just`, so `sudo` and the flake path stay consistent.

## Layout

- `hosts/<name>/default.nix` — one file per machine, imported by `hosts/default.nix` which lists every darwin and nixos host and wires `secrets`/`deployHosts` into it.
- `modules/darwin/`, `modules/nixos/`, `modules/shared/` — reusable config, imported by the per-host files. `modules/shared` applies to every host regardless of platform.
- `lib/mkDarwinSystem.nix`, `lib/mkNixosSystem.nix` — the flake's system builders; `flake.nix` calls these per host rather than defining `darwinSystem`/`nixosSystem` inline.

## Secrets

- Managed with `agenix`, encrypted files pulled from the separate `gustavclausen/nix-secrets` flake input (`secrets` arg, threaded into every host via `_module.args`).
- Reference a secret with `age.secrets.<name> = { file = "${secrets}/..."; ... }`; never inline plaintext credentials in this repo.

## Gotchas

- Homebrew taps (`nix-homebrew.taps` in `lib/mkDarwinSystem.nix`) are declared with `mutableTaps = false` — add new casks/formulae through the module, not `brew tap`/`brew install` by hand.
- `just clean` runs `nix-collect-garbage` both system-wide (`sudo`) and user-level — confirm with the user before running it; it deletes old generations.
