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
    ente-auth
    feishin
    freetube
    jellyfin-media-player
    #libreoffice-qt-fresh
    mangohud
    # Workaround for Electron 41 WASM-streaming renderer crash (electron/electron#52178).
    # electron_41 (bundled default) crashes on startup; electron_42 (>=42.4.1) has the fix.
    # Remove once nixpkgs' obsidian picks up a patched electron_41.
    (obsidian.override {electron = electron_42;})
    picard
    pocket-casts
    jetbrains.pycharm
    jetbrains.rust-rover
    signal-desktop
    sone
    # --disable-gpu: vesktop's Electron GPU process holds an amdgpu DMA fence that never
    # signals during the hibernate freeze -> amdgpu_vm_fini/dma_fence_wait_timeout hangs and
    # hibernate aborts with "Device or resource busy". Forcing GPU off lets hibernate work
    # with vesktop running. Vesktop HW-accel is buggy on AMD/Wayland:
    # https://github.com/Vencord/Vesktop/issues/1009
    (pkgs.symlinkJoin {
      name = "vesktop";
      paths = [pkgs.vesktop];
      nativeBuildInputs = [pkgs.makeWrapper];
      postBuild = "wrapProgram $out/bin/vesktop --add-flags \"--disable-gpu\"";
    })

    android-studio
    jdk17
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
    # Pin pre-26.05 default path; remove on a fresh stateVersion >= 26.05 install.
    configPath = ".mozilla/firefox";
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
    enableMcpIntegration = true;
    extraPackages = [
      pkgs.basedpyright
      pkgs.jdt-language-server
      pkgs.nixd
      pkgs.nixfmt
      pkgs.ruff
      pkgs.rustfmt
    ];
    settings = {
      lsp = true; # https://github.com/anomalyco/opencode/issues/23566
      formatter = true;
      plugin = [
        "@tickernelz/opencode-mem@latest"
        "oh-my-opencode-slim@latest"
      ];
      agent = {
        explore.disable = true;
        general.disable = true;
      };
      mcp.kagi = {
        type = "remote";
        url = "https://mcp.kagi.com/mcp";
        enabled = true;
        # opencode's {file:} resolver can't shell-expand ${XDG_RUNTIME_DIR}; rewrite it to
        # opencode's own {env:} token (opencode runs the env pass before the file pass, and
        # trims file contents, dropping the secret's trailing newline).
        headers.Authorization = "Bearer {file:${
          lib.replaceStrings ["\${XDG_RUNTIME_DIR}"] ["{env:XDG_RUNTIME_DIR}"]
          config.age.secrets.kagi-api-key.path
        }}";
      };
    };
    tui = {
      theme = "zenburn";
      plugin = ["oh-my-opencode-slim"];
    };
  };

  # opencode reads OPENCODE_EXPERIMENTAL_* from the process environment, not its
  # config file (opencode.json has no `env` field, unlike claude-code's settings),
  # and the upstream `programs.opencode` home-manager module exposes no env option
  # nor wraps the binary with --set. So this must come from the shell environment;
  # set globally until a scoped mechanism (shell wrapper / upstream env option) exists.
  home.sessionVariables.OPENCODE_EXPERIMENTAL_BACKGROUND_SUBAGENTS = "true";

  xdg.configFile."opencode/oh-my-opencode-slim.jsonc".source = ./oh-my-opencode-slim.jsonc;

  programs.vicinae = {
    enable = true;
    systemd.enable = true;
  };

  programs.vscode.enable = true;

  programs.zed-editor = {
    enable = true;
    extensions = [
      "OpenCode"
      "zedburn"
    ];
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  services.udiskie.enable = true; # Auto mount usb drives
}
