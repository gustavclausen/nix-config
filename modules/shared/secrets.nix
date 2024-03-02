{
  pkgs,
  currentSystemUser,
  ...
}: let
  homePath =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "/Users/${currentSystemUser}"
    else "/home/${currentSystemUser}";
  sshHome = "${homePath}/.ssh";
in {
  age.identityPaths = [
    "${sshHome}/id_ed25519"
  ];
}
