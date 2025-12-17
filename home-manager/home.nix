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
    #android-studio
    #anki
    appimage-run
    arduino-ide
    bitwarden-desktop
    bottles
    (btop.override {rocmSupport = true;})
    cargo-generate
    cachix
    caffeine-ng
    calibre
    claude-code
    cura-appimage
    #darktable
    dbeaver-bin
    docker-compose
    efibootmgr
    espflash
    esp-generate
    ente-auth
    freecad
    freetube
    fd
    #feishin
    firefoxpwa
    freetube
    fzf
    gcc # for rust
    gnucash
    #jellyfin-media-player qtwebengine has a CVE
    jetbrains.pycharm-professional
    jetbrains.rust-rover
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
    pkg-config # For rustup
    protonup-qt
    python3
    ripgrep
    ripgrep-all
    rustup
    signal-desktop
    thunderbird
    unzip
    uv
    xivlauncher
    vesktop
  ];

  home = {
    username = "ciferkey";
    homeDirectory = "/home/ciferkey";
  };

  programs.atuin.enable = true;

  programs.autojump.enable = true;

  programs.bat = {
    enable = true;
    config = {
      theme = "zenburn";
    };
  };

  programs.chromium = {
    enable = true;
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      line-numbers = true;
      side-by-side = true;
      syntax-theme = "zenburn";
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.eza = {
    enable = true;
    git = true;
  };

  programs.fish = {
    enable = true;
    plugins = [
      { 
        name = "fzf-fish"; 
        src = pkgs.fishPlugins.fzf-fish.src;
      }
      { 
        name = "tide"; 
        src = pkgs.fishPlugins.tide.src;
      }
      {
        name = "tmux";
        src = pkgs.fetchFromGitHub {
          owner = "budimanjojo";
          repo = "tmux.fish";
          rev = "e5874377b3d1359877053df7a9ea8aaeaf3bed2b";
          sha256 = "sha256-+Z49BvoEdnvkuGibsHd5KjLQNUj+qJKHgq4Zey26s4k=";
        };
      }
    ];
    shellAliases = {
     g = "git";
     rebuild = "nh os switch .";
     reflake = "nix flake update";
     rehome = "nh home switch .";
     repair = "sudo nix-store --repair --verify --check-contents";
     ks = "kitten ssh";
    };
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

  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
    settings.git_protocol = "ssh";
  };

  programs.gh-dash.enable = true;

  programs.git = {
    enable = true;
    settings = {
      alias = {
        cam = "commit -am";
        ch = "checkout HEAD --";
        d = "-p diff";
        lom = "pull origin master";
        pom = "push origin master";
        rh = "reset --hard HEAD";
        s = "status";
      };
      user = {
        name  = "ciferkey";
        email = "ciferkey@gmail.com";
      };
      extraConfig = {
        pull.rebase = true;
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

  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      font-family = "Inconsolata LGC Nerd Font Mono";
      theme = "Zenburn";
      keybind = [
        # https://ghostty.org/docs/config/keybind/reference#toggle_quick_terminal
        "global:super+a=toggle_quick_terminal"
      ];
    };
  };

  programs.navi = {
    enable = true;
  };
  
  programs.neovim = {
    defaultEditor = true;
    enable = true;
    extraConfig = ''
      colorscheme zenburn
      set mouse=a
      set nu
    '';
    extraPackages = [
      pkgs.ripgrep
      pkgs.wl-clipboard
    ];
    plugins = [
      pkgs.vimPlugins.vim-nix
      pkgs.vimPlugins.nvim-treesitter.withAllGrammars
      pkgs.vimPlugins.zenburn
    ];
    vimAlias = true;
  };

  programs.nix-index = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.tmux = {
    enable = true;
    mouse = true;
    plugins = with pkgs; [
      tmuxPlugins.better-mouse-mode
      tmuxPlugins.resurrect
      tmuxPlugins.continuum
    ];
    terminal = "tmux-256color";
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
