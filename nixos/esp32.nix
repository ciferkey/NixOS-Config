{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {

  users.groups.plugdev = {}; # need to make explicitly

  users.users.ciferkey = {
    isNormalUser = true;
    description = "ciferkey";
    extraGroups = [
      "dialout" # Allow access to serial device
      "plugdev" # For esp32 flashing
    ];
  };

  services = {
    udev = {
      packages = with pkgs; [
        probe-rs-tools
      ];
    };
  };

}
