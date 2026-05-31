{
  secrets,
  deployHosts,
}:
{
  darwin = {
    "personal-macbook-pro-m5" = {
      arch = "aarch64";
      user = "gustavkc";
      hostConfig =
        { ... }:
        {
          imports = [ ./personal-macbook-pro-m5 ];
          _module.args = {
            inherit secrets deployHosts;
          };
        };
    };

    "personal-mac-mini" = {
      arch = "aarch64";
      user = "gustavclausen";
      hostConfig =
        { ... }:
        {
          imports = [ ./personal-mac-mini ];
          _module.args = {
            inherit secrets deployHosts;
          };
        };
    };
  };

  nixos = {
    coolify = {
      system = "aarch64-linux";
      hostConfig =
        { ... }:
        {
          imports = [ ./coolify ];
          _module.args = {
            inherit secrets;
          };
        };
      deploy = { };
    };

    coder = {
      system = "aarch64-linux";
      hostConfig =
        { ... }:
        {
          imports = [ ./coder ];
          _module.args = {
            inherit secrets;
          };
        };
      deploy = { };
    };
  };
}
