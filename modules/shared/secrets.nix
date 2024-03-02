{homePath, ...}: let
  sshHome = "${homePath}/.ssh";
in {
  age.identityPaths = [
    "${sshHome}/id_ed25519"
  ];
}
