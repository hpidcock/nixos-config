{ config, pkgs, unstable-pkgs, lib, ... }:

{
  home.username = "hpidcock";
  home.homeDirectory = "/home/hpidcock";
  home.stateVersion = "24.05";

  home.packages = [
    pkgs.zsh
    pkgs.vim
    pkgs.git
    pkgs.gh
    unstable-pkgs.go_1_23
    pkgs.gnumake
    pkgs.htop
    pkgs.wget
    pkgs.curl

    unstable-pkgs.nixgl.nixGLMesa
    unstable-pkgs.sway
    #pkgs.swaylock # Use the ubuntu one, since it actually works with pam.
    unstable-pkgs.alacritty
    pkgs.mako
    pkgs.grim
    pkgs.waybar
    pkgs.wl-clipboard
    pkgs.slurp
    pkgs.wofi
    pkgs.wl-mirror

    pkgs.spotify
    unstable-pkgs.element-desktop
    unstable-pkgs.vscode
    unstable-pkgs.logseq
    unstable-pkgs._1password-cli
    unstable-pkgs._1password-gui

    pkgs.podman
    pkgs.minikube
    pkgs.kubectl
    pkgs.awscli2
    unstable-pkgs.google-cloud-sdk
    pkgs.ssm-session-manager-plugin

    pkgs.wineWowPackages.stable
    pkgs.winetricks

    (import ./juju-dev-shell/shell.nix {pkgs=pkgs; unstable-pkgs=unstable-pkgs; lib=lib;})
  ];

  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  home.sessionVariables = {
    EDITOR = "vim";
    PATH = "/home/hpidcock/go/bin:$PATH";
  };

  home.language = {
    base = "en_AU.utf8";
  };

  programs.git = {
    enable = true;
    userName = "Harry Pidcock";
    userEmail = "harry.pidcock@canonical.com";
    signing = {
      signByDefault = true;
      key = "47A14177CFB4DB92";
    };
    extraConfig.url = {
      "git+ssh://git.launchpad.net/" = {
        insteadOf = "lp:";
      };
      "ssh://git@github.com/" = {
        insteadOf = "https://github.com/";
      };
    };
  };

  programs.alacritty = {
    enable = true;
    package = unstable-pkgs.alacritty;
    settings = {
      general = {
        live_config_reload = true;
      };
      font.size = 17.0;
      font.bold.family = "DejaVu Sans Mono";
      font.italic.family = "DejaVu Sans Mono";
      font.normal.family = "DejaVu Sans Mono";
      cursor = {
        style = "Block";
        unfocused_hollow = true;
      };
      mouse.hide_when_typing = false;
      scrolling.history = 10000;
      scrolling.multiplier = 3;
      selection.save_to_clipboard = false;
      terminal = {
        shell.program = "zsh";
      };
      window = {
        decorations = "full";
        dynamic_padding = false;
        opacity = 0.85;
        startup_mode = "Windowed";
        padding.x = 2;
        padding.y = 2;
      };
      colors = {
        draw_bold_text_with_bright_colors = true;
        primary = {
          background = "0x002b36";
          foreground = "0x839496";
        };
        bright = {
          black = "0x002b36";
          blue = "0x839496";
          cyan = "0x93a1a1";
          green = "0x586e75";
          magenta = "0x6c71c4";
          red = "0xcb4b16";
          white = "0xfdf6e3";
          yellow = "0x657b83";
        };
        normal = {
          black = "0x073642";
          blue = "0x268bd2";
          cyan = "0x2aa198";
          green = "0x859900";
          magenta = "0xd33682";
          red = "0xdc322f";
          white = "0xeee8d5";
          yellow = "0xb58900";
        };
      };
    };
  };

  programs.zsh = {
    enable = true;
    initExtraFirst = ''
        zvm_config() {
          ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BLOCK
          ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_UNDERLINE
        }        
        function modver() {
	  TZ=UTC git --no-pager show \
	  --quiet \
	  --abbrev=12 \
	  --date='format-local:%Y%m%d%H%M%S' \
	  --format="%cd-%h"
	}
	alias modver=modver
	function juju_kill_controllers() {
	  juju controllers --format=yaml | yq '.controllers | keys | .[]' | xargs -n 1 juju kill-controller --no-prompt --timeout 0s
	}
	alias juju-kill-controllers=juju_kill_controllers
      '';
    oh-my-zsh = {
      enable = true;
      plugins = [];
      theme = "agnoster";
    };
    plugins = [
      {
        name = "vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      }
    ];
  };

  programs.vscode = {
    enable = true;
    package = unstable-pkgs.vscode;
    extensions = with unstable-pkgs.vscode-marketplace; [
      golang.go
      babakks.vscode-go-test-suite
      bbenoist.nix
      waderyan.gitblame
    ];
    userSettings = {
      "workbench.colorTheme" = "Solarized Dark";
      "window.menuBarVisibility" = "toggle";
      "files.simpleDialog.enable" = true;
      "extensions.ignoreRecommendations" = true;
      "editor.scrollbar.verticalScrollbarSize" = 8;
      "editor.scrollbar.horizontalScrollbarSize" = 8;
      "editor.minimap.maxColumn" = 100;
      "scm.showHistoryGraph" = false;
      "scm.showChangesSummary" = false;
    };
  };

  programs.wofi = {
    enable = true;
    style = ''
      window {
        margin: 0px;
        border: 1px solid #928374;
        background-color: #002b36;
      }
      #input {
        margin: 5px;
        border: none;
        color: #839496;
        background-color: #073642;
      }
      #inner-box {
        margin: 5px;
        border: none;
        background-color: #002b36;
      }
      #outer-box {
        margin: 5px;
        border: none;
        background-color: #002b36;
      }
      #scroll {
        margin: 0px;
        border: none;
      }
      #text {
        margin: 5px;
        border: none;
        color: #839496;
      }
      #entry:selected {
        background-color: #073642;
      }
      '';
  };

  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };
  programs.home-manager.enable = true;
}
