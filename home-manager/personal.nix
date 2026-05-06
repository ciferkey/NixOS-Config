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
  ];

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    appimage-run
    bottles
    caffeine-ng
    ente-auth
    feishin
    freetube
    (heroic.override {
      extraPkgs = pkgs':
        with pkgs'; [
          gamescope
          gamemode
        ];
    })
    jellyfin-media-player
    libreoffice-qt-fresh
    mangohud
    obsidian
    picard
    pocket-casts
    jetbrains.pycharm
    signal-desktop
    vesktop
  ];

  home = {
    username = "ciferkey";
    homeDirectory = "/home/ciferkey";
  };

  programs.chromium = {
    enable = true;
  };

  programs.element-desktop = {
    enable = true;
  };

  programs.firefox = {
    enable = true;
    profiles.default = {
      settings = {
        "media.ffmpeg.vaapi.enabled" = "true";
        "extensions.formautofill.creditCards.enabled" = false; # Disable credit card autofill, so I can use bitwarden instead.

        "browser.startup.page" = 3; # Restore previous session

        "browser.newtabpage.enabled" = false;
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        "browser.newtabpage.activity-stream.feeds.topsites" = false;
        "browser.newtabpage.activity-stream.showSearch" = false;

        "browser.contentblocking.category" = "strict";
        "dom.security.https_only_mode" = true;
        "dom.security.https_only_mode_ever_enabled" = true;
        "privacy.donottrackheader.enabled" = true;

        "sidebar.verticalTabs" = true;

        "browser.tabs.warnOnOpen" = false;
        "browser.download.useDownloadDir" = false;
        "general.autoScroll" = true;
        "media.eme.enabled" = true;
        "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
      };
    };
    nativeMessagingHosts = [
      pkgs.kdePackages.plasma-browser-integration
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

  programs.opencode = {
    enable = true;
    extraPackages = [
      pkgs.nixd # lsp for nix
      pkgs.basedpyright
    ];
    settings = {
      lsp = true; # https://github.com/anomalyco/opencode/issues/23566
      plugin = [
        "@tickernelz/opencode-mem@latest"
        "@plannotator/opencode@latest"
      ];
    };
    tui.theme = "zenburn";
  };

  programs.vscode.enable = true;

  programs.zed-editor = {
    enable = true;
    extensions = [ "OpenCode" "zedburn" ];
  };

  # TODO: shared programs.mcp.servers section

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  services.udiskie.enable = true; # Auto mount usb drives
}
