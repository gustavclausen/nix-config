default:
  @just --list

[group('nix')]
update:
  nix flake update

[group('nix')]
clean:
  # Unused nix store entries (system-wide)
  sudo nix-collect-garbage --delete-older-than 14d
  # Unused nix store entries (user-specific)
  nix-collect-garbage --delete-older-than 14d

[macos]
[group('nix')]
build host:
  nix build --extra-experimental-features 'nix-command flakes' ".#darwinConfigurations.{{host}}.system"

[linux]
[group('nix')]
build host:
  nix build --extra-experimental-features 'nix-command flakes' ".#nixosConfigurations.{{host}}.config.system.build.toplevel"

[macos]
[group('nix')]
switch host: (build host)
  sudo ./result/sw/bin/darwin-rebuild switch --flake "$(pwd)#{{host}}"

[linux]
[group('nix')]
switch host: (build host)
  sudo nixos-rebuild switch --flake "$(pwd)#{{host}}"

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
