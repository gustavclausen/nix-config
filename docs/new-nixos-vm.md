# Deploy New NixOS VM

## Provision VM

<details>
<summary>UTM (macOS)</summary>

Create new VM with the following settings:

- Boot: UEFI
- Boot ISO: NixOS minimal ISO from <https://nixos.org/download/>
- Display (**Edit** -> **Display** -> **Emulated Display Card**): `virtio-gpu-pci`
    
</details>

## Prepare VM

<details>
<summary>UTM (macOS)</summary>

- Set password for **nixos** user: `passwd nixos`
- Get IP: `ip addr`

</details>

## Install NixOS

NixOS is installed using nixos-anywhere: <https://github.com/nix-community/nixos-anywhere>

```bash


```bash
temp=$(mktemp -d)
trap 'rm -rf "$temp"' EXIT

install -d -m755 "$temp/etc/ssh"
cp -RL ~/.ssh/vm_ed25519 "$temp/etc/ssh/vm_ed25519"
chmod 600 "$temp/etc/ssh/vm_ed25519"
```

<details>
<summary>Password authentication</summary>

```bash
SSHPASS="<PASSWORD_FOR_NIXOS_USER>" nix run github:nix-community/nixos-anywhere -- \
  --build-on remote \
  --flake .#<HOSTNAME> \
  --target-host nixos@<VM_IP_ADDRESS> \
  --env-password \
  --generate-hardware-config nixos-generate-config ./hosts/<HOSTNAME>/hardware-configuration.nix \
  --extra-files "$temp"
```

</details>

## Post-configuration

<details>
<summary>UTM (macOS)</summary>

- Remove ISO
- Remove display: `Edit` -> `Display` -> `Remove`

</details>
