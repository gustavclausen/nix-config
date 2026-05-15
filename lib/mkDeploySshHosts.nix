{ lib }:
{
  tailnet ? "tail695ae9.ts.net",
  defaultKeyName ? "vm",
  defaultPort ? 22,
}:
deployHosts:
lib.mapAttrs (_: deployHost: {
  hostname = "${deployHost.hostname}.${tailnet}";
  user = deployHost.sshUser;
  port = deployHost.sshPort or defaultPort;
  keyName = deployHost.keyName or defaultKeyName;
}) deployHosts
