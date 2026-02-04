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
    ./terminal.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    #anki
    appimage-run
    bitwarden-desktop
    bottles
    (btop.override {rocmSupport = true;})
    cachix
    caffeine-ng
    calibre
    claude-code
    cura-appimage
    darktable
    docker-compose
    efibootmgr
    ente-auth
    freetube
    fd
    feishin
    freetube
    fzf
    jellyfin-media-player 
    kdePackages.kasts
    #lutris
    mangohud
    nerd-fonts.inconsolata-lgc
    nerd-fonts.hack
    nh
    nix-du
    nixpkgs-review
    nix-update
    obsidian
    picard
    protonup-qt
    python3
    ripgrep
    ripgrep-all
    signal-desktop
    thunderbird
    unzip
    uv
    #xivlauncher
    vesktop
  ];

  home = {
    username = "ciferkey";
    homeDirectory = "/home/ciferkey";
  };

  #programs.autojump.enable = true;

  programs.chromium = {
    enable = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.element-desktop = {
    enable = true;
  };

  programs.firefox = {
    enable = true;
    profiles.default = {
      settings = {
        "media.ffmpeg.vaapi.enabled" = "true";
      };
    };
    nativeMessagingHosts = [ 
      pkgs.firefoxpwa
      pkgs.kdePackages.plasma-browser-integration
      pkgs.tridactyl-native
    ]; 
    package = pkgs.firefox.override {
      cfg = {
        speechSynthesisSupport = true;
      };
    };
  };

  programs.hexchat = {
    enable = true;
    settings = {
      irc_nick1 = "ciferkey";
      irc_username = "ciferkey";
    };
    theme = pkgs.fetchzip {
      url = "https://dl.hexchat.net/themes/Zenburn.hct#Zenburn.zip";
      sha256 = "sha256-VIv+IeCwq+jq+F5yyz5J3CSCvQaNh07uc81kVNMqxsY=";
      stripRoot = false;
    };
  };

  programs.home-manager.enable = true;

  programs.kitty = {
    enable = true;
    font.name = "Inconsolata LGC Nerd Font Mono";
    themeFile = "Zenburn";
    settings = {
      adjust_line_height = 1; # Needed to fix nerd fonts
      wayland_titlebar_color = "background";
    };
  };

  programs.vscode.enable = true;



  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";

  services.udiskie.enable = true; # Auto mount usb drives

  # Auto cleanup home manager generations, since I do not run home manager as a nix module.
  services.home-manager = {
    autoExpire = {
      enable = true;
      store.cleanup = true;
      store.options = "--delete-older-than 14d";
      timestamp = "-14 days";
    };
  };
}
