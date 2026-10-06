{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  networking.hostName = "nixos";

  # Fix EDID for monitor on AMD
  hardware.display.edid.linuxhw."XL2420G_2014" = ["BNQ7F39" "XL2420G" "2014" "2E7C0DC569A3"];
  hardware.display.outputs."DP-2".edid = "XL2420G_2014.bin";
  hardware.display.outputs."DP-2".mode = "e";

  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;

  # Steam Frame wireless adapter needs 6 GHz, which the world regdom (00) disables.
  boot.extraModprobeConfig = ''
    options cfg80211 ieee80211_regdom=US
  '';
}
