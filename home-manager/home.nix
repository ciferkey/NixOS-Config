# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
    inputs.nvf.homeManagerModules.default
    ./terminal.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications

      # Alias llm-agents' prebuilt (cache-backed) agent packages into pkgs so call
      # sites can use pkgs.claude-code / pkgs.opencode / pkgs.omp.
      # NB: use the .packages output, NOT llm-agents.overlays.shared-nixpkgs — that
      # overlay rebuilds against our nixpkgs and forfeits the numtide binary cache.
      (final: prev: {
        inherit
          (inputs.llm-agents.packages.${prev.stdenv.hostPlatform.system})
          claude-code
          opencode
          omp
          ;
      })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # vesktop pins electron_40, which went EOL 2026-07. Remove once vesktop bumps electron.
      permittedInsecurePackages = [
        "electron-40.10.5"
      ];
    };
  };

  home.packages = with pkgs; [
    cachix
    nerd-fonts.inconsolata-lgc
    nerd-fonts.hack
    omp
    poppler-utils # for pdf handling
    sox # for voice in claude code
  ];

  programs.home-manager.enable = true;

  programs.thunderbird = {
    enable = true;
    settings = {
      "intl.date_time.pattern_override.time_short" = "h:mm a";
      "intl.date_time.pattern_override.time_medium" = "h:mm:ss a";

      # No new-mail indicators: popup, sound, badge, tray icon.
      "mail.biff.show_alert" = false;
      "mail.biff.play_sound" = false;
      "mail.biff.show_badge" = false;
      "mail.biff.show_tray_icon" = false;
      "mail.biff.show_tray_icon_always" = false;
    };
    profiles.default.isDefault = true;
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
