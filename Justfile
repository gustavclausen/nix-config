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
  NIXPKGS_ALLOW_UNFREE=1 nix build --extra-experimental-features 'nix-command flakes' ".#darwinConfigurations.{{host}}.system"

[macos]
[group('nix')]
switch host: (build host)
  ./result/sw/bin/darwin-rebuild switch --flake "$(pwd)#{{host}}"

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
