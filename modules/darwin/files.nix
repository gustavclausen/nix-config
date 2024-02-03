{
  user,
  config,
  pkgs,
  ...
}: let
  home = "${config.users.users.${user}.home}";
in {
  "${home}/.gnupg/gpg-agent.conf" = {
    text = ''
      grab
      default-cache-ttl 60480000
      max-cache-ttl 60480000
      pinentry-program ${pkgs.pinentry_mac}/Applications/pinentry-mac.app/Contents/MacOS/pinentry-mac
    '';
  };

  "${home}/.gnupg/gpg.conf" = {
    text = ''
      use-agent
    '';
  };
}
