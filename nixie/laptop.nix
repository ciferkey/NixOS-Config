{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {

  boot.initrd.systemd.enable = true;
  swapDevices = [{
    device = "/.swapvol/swapfile";
    size = 32 * 1024;
  }];

}
