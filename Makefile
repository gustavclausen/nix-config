UNAME := $(shell uname)

check-env:
ifndef FLAKENAME
	$(error FLAKENAME is undefined)
endif

build: check-env
ifeq ($(UNAME), Darwin)
	export NIXPKGS_ALLOW_UNFREE=1
	nix build --extra-experimental-features 'nix-command flakes' ".#darwinConfigurations.${FLAKENAME}.system"
else
	echo "Non-Darwin installations not supported yet."
endif

switch: build
ifeq ($(UNAME), Darwin)
	./result/sw/bin/darwin-rebuild switch --flake "$$(pwd)#${FLAKENAME}"
else
	echo "Non-Darwin installations not supported yet."
endif

hm-switch:
	home-manager switch --flake .#${FLAKENAME}

bootstrap:
	nix run --extra-experimental-features "nix-command flakes" nixpkgs#home-manager -- --extra-experimental-features "nix-command flakes" switch --flake .#${FLAKENAME}

rollback: check-env
		/run/current-system/sw/bin/darwin-rebuild --list-generations; \
		echo "Generation number: "; \
		read GEN_NUM; \
		if [[ -z "$$GEN_NUM" ]]; then \
				echo "No generation number entered. Aborting rollback."; \
				exit 1; \
		fi; \
		/run/current-system/sw/bin/darwin-rebuild switch --flake "$$(pwd)#${FLAKENAME}" --switch-generation "$$GEN_NUM";

update-deps:
	nix flake update

cleanup:
	nix-collect-garbage --delete-old
	sudo nix-collect-garbage -d
