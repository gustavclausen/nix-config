default:
  @just --list

# Host recorded by a previous `just switch` (see modules/shared/default.nix),
# used to auto-infer the host when one isn't passed explicitly.
current_host := `cat /etc/current-nix-host 2>/dev/null || true`

[group('nix')]
update:
  nix flake update

[group('nix')]
clean:
  # Unused nix store entries (system-wide)
  sudo nix-collect-garbage --delete-older-than 14d
  # Unused nix store entries (user-specific)
  nix-collect-garbage --delete-older-than 14d

[group('nix')]
deploy host:
  nix develop --command deploy "$(pwd)#{{host}}"

[macos]
[group('nix')]
build host=current_host: (_require-host host)
  nix build --extra-experimental-features 'nix-command flakes' ".#darwinConfigurations.{{host}}.system"

[linux]
[group('nix')]
build host=current_host: (_require-host host)
  nix build --extra-experimental-features 'nix-command flakes' ".#nixosConfigurations.{{host}}.config.system.build.toplevel"

[macos]
[group('nix')]
switch host=current_host: (build host)
  sudo ./result/sw/bin/darwin-rebuild switch --flake "$(pwd)#{{host}}"

[linux]
[group('nix')]
switch host=current_host: (build host)
  sudo nixos-rebuild switch --flake "$(pwd)#{{host}}"

[private]
_require-host host:
  #!/usr/bin/env bash
  set -euo pipefail
  if [[ -z "{{host}}" ]]; then
    echo "error: no host given and none could be auto-inferred (this system hasn't been switched with this flake before)." >&2
    echo "Run 'just switch <hostname>' once, e.g.: just switch personal-macbook-pro-m5" >&2
    exit 1
  fi

[macos]
[group('nix')]
rollback host:
  /run/current-system/sw/bin/darwin-rebuild --list-generations; \
  echo "Generation number: "; \
  read GEN_NUM; \
  if [[ -z "$GEN_NUM" ]]; then \
      echo "No generation number entered. Aborting rollback."; \
      exit 1; \
  fi; \
  /run/current-system/sw/bin/darwin-rebuild switch --flake "$(pwd)#{{host}}" --switch-generation "$GEN_NUM";

[linux]
[group('nix')]
rollback host:
  sudo nix-env --profile /nix/var/nix/profiles/system --list-generations; \
  echo "Generation number: "; \
  read GEN_NUM; \
  if [[ -z "$GEN_NUM" ]]; then \
      echo "No generation number entered. Aborting rollback."; \
      exit 1; \
  fi; \
  sudo nix-env --profile /nix/var/nix/profiles/system --switch-generation "$GEN_NUM"; \
  sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch;
