{
  pkgs,
  currentSystemUser,
  gitUser,
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

  age.secrets."github-ssh-key" = {
    symlink = true;
    path = "${sshHome}/id_github";
    file = "${gitUser.privSshKey}";
    mode = "600";
    owner = "${currentSystemUser}";
    group = "staff";
  };

  age.secrets."github-signing-key" = {
    symlink = true;
    path = "${sshHome}/pgp_github.key";
    file = "${gitUser.privSigningKey}";
    mode = "600";
    owner = "${currentSystemUser}";
  };
}
