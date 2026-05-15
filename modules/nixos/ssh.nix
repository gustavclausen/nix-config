{
  ...
}:
{
  services.openssh = {
    enable = true;
    openFirewall = false;

    settings = {
      # Security hardening
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
      KbdInteractiveAuthentication = false;

      UseDns = false; # Performance

      PubkeyAuthentication = true;
    };

    extraConfig = ''
      ClientAliveInterval 60
      ClientAliveCountMax 3
    '';
  };

  networking = {
    firewall = {
      allowedTCPPorts = [ 22 ];
    };
  };
}
