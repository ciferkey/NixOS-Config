{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # Fix EDID for monitor on AMD
  hardware.display.edid.linuxhw."XL2420G_2014" = ["BNQ7F39" "XL2420G" "2014" "2E7C0DC569A3"];
  hardware.display.outputs."DP-2".edid = "XL2420G_2014.bin";
  hardware.display.outputs."DP-2".mode = "e";
}
