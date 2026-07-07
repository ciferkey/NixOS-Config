{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  age.secrets.kagi-api-key = {
    rekeyFile = ./secrets/kagi_api_key.age;
  };

  age.rekey = {
    masterIdentities = [
      "/home/ciferkey/.ssh/yubikey-identity.txt"
    ];
    storageMode = "local";
  };

  # Enable integration here, rather than for every potential program.
  home.shell.enableFishIntegration = true;

  programs.atuin.enable = true;

  programs.bat = {
    enable = true;
    config = {
      theme = "zenburn";
    };
  };

  programs.claude-code = {
    enable = true;
    #package = pkgs.claude-code-fhs;
    mcpServers = {
      kagi = {
        type = "http";
        url = "https://mcp.kagi.com/mcp";
        headersHelper = let
          authHeader = pkgs.writeShellScript "kagi-mcp-auth" ''
            ${pkgs.jq}/bin/jq -nc \
              --arg key "$(cat ${config.age.secrets.kagi-api-key.path})" \
              '{"Authorization": "Bearer \($key)"}'
          '';
        in "${authHeader}";
      };
    };
    settings = {
      env = {
        CLAUDE_CODE_AUTO_COMPACT_WINDOW = "1000000"; # https://github.com/anthropics/claude-code/issues/43989
        CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS = "1";
        CLAUDE_CODE_NO_FLICKER = 1;
        DISABLE_INSTALLATION_CHECKS = "1"; # https://github.com/anthropics/claude-code/issues/17289
      };
      alwaysThinkingEnabled = true;
      enabledPlugins = {
        "pyright-lsp@claude-plugins-official" = true;
        "claude-notifications-go@claude-notifications-go" = true;
      };
      extraKnownMarketplaces = {
        marketplace-name = {
          source = {
            source = "github";
            repo = "777genius/claude-notifications-go";
          };
        };
      };
      model = "opus";
      permissions = {
        defaultMode = "plan";
        deny = ["WebSearch"];
      };
      showClearContextOnPlanAccept = true;
      showThinkingSummaries = true;
      statusLine = let
        ccstatusline = pkgs.writeShellApplication {
          name = "ccstatusline";
          runtimeInputs = [pkgs.bun pkgs.nodejs];
          text = ''exec bunx ccstatusline@latest "$@"'';
        };
      in {
        type = "command";
        command = lib.getExe ccstatusline;
        padding = 0;
      };
    };
  };
  xdg.configFile."ccstatusline/settings.json".source = ./ccstatusline-settings.json;

  programs.btop = {
    enable = true;
    package = pkgs.btop.override {rocmSupport = true;};
    settings = {
      theme = "tty";
    };
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

  home.packages = with pkgs; [
    docker-compose
    jq
    python3
    ripgrep-all
    unzip
    uv
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.eza = {
    enable = true;
    git = true;
    icons = "auto";
  };

  programs.fd.enable = true;

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
    ];
    shellAliases = {
      g = "git";
      rbaz = "sudo efibootmgr -n 0 && sudo reboot now";
      rebuild = "nh os switch .";
      reflake = "nix flake update";
      rehome = "nh home switch .";
      repair = "sudo nix-store --repair --verify --check-contents";
    };
  };

  programs.fzf = {
    enable = true;
    # Atuin owns Ctrl-R in fish; disable fzf's history widget to avoid the conflict.
    historyWidget.fish.command = "";
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
        name = "ciferkey";
        email = "ciferkey@gmail.com";
      };
      pull.rebase = true;
      merge.tool = "nvimdiff";
    };
    signing.format = null;
  };

  programs.ghostty = {
    enable = true;
    settings = {
      font-family = "Inconsolata LGC Nerd Font Mono";
      theme = "Zenburn";
      keybind = [
        # https://ghostty.org/docs/config/keybind/reference#toggle_quick_terminal
        "global:super+a=toggle_quick_terminal"
      ];
      quick-terminal-size = "50%";
      # Fixes for ssh, https://ghostty.org/docs/config/reference#shell-integration-features
      shell-integration-features = [
        "ssh-terminfo"
        "ssh-env"
      ];
    };
  };

  programs.jujutsu = {
    enable = true;
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
    # Pin pre-26.05 defaults; remove on a fresh stateVersion >= 26.05 install.
    withRuby = false;
    withPython3 = false;
  };

  programs.nh = {
    enable = true;
    clean = {
      enable = true;
      dates = "weekly";
      extraArgs = "--keep-since 14d";
    };
  };

  programs.nix-index = {
    enable = true;
  };

  programs.ripgrep.enable = true;

  programs.zellij = {
    enable = true;
    enableFishIntegration = true; # https://github.com/nix-community/home-manager/pull/6695clade
    attachExistingSession = true;
    settings = {
      theme = "ansi";
      focus_follows_mouse = true;
    };
  };

  programs.zoxide = {
    enable = true;
    options = ["--cmd" "cd"];
  };
}
