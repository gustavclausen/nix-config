{
  pkgs,
  homePath,
  ...
}: {
  "${homePath}/.gnupg/gpg-agent.conf" = {
    text = ''
      grab
      default-cache-ttl 60480000
      max-cache-ttl 60480000
      pinentry-program ${pkgs.pinentry_mac}/Applications/pinentry-mac.app/Contents/MacOS/pinentry-mac
    '';
  };

  "${homePath}/.gnupg/gpg.conf" = {
    text = ''
      use-agent
    '';
  };
}
