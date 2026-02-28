{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {

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
    package = pkgs.claude-code-bin;
    settings = {
      alwaysThinkingEnabled = true;
      statusLine = {
        type = "command";
        command = "${pkgs.bun}/bin/bunx ccstatusline@latest";
        padding = 0;
      };
    };
  };
  xdg.configFile."ccstatusline/settings.json".source = ./ccstatusline-settings.json;

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      line-numbers = true;
      side-by-side = true;
      syntax-theme = "zenburn";
    };
  };

  programs.direnv.enable = true;

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
     rebuild = "nh os switch .";
     reflake = "nix flake update";
     rehome = "nh home switch .";
     repair = "sudo nix-store --repair --verify --check-contents";
    };
  };

  programs.fzf.enable = true;

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
    };
  };

  programs.zoxide = {
    enable = true;
  };
}
