{ pkgs, ... }:
{
  imports = [
    ./desktop.nix
  ];

  home.stateVersion = "25.11";
  home.preferXdgDirectories = true;
  home.shell.enableFishIntegration = true;
  home.packages = with pkgs; [
    # Language Servers
    nil # Nix

    # Formatters
    nixfmt # Nix
  ];

  programs.bash = {
    enable = true;
    initExtra = ''
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';
  };

  programs.fish = {
    enable = true;
    preferAbbrs = true;
    loginShellInit = ''
      set -gx PATH "$HOME/.local/bin:$PATH"
    '';
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
      fish_config theme choose Dracula | source
      fish_config prompt choose scales | source
    '';
    shellAbbrs = {
      nrs = "sudo nixos-rebuild switch";
    };
    shellAliases = {
      ls = "eza";
      tree = "eza --tree";
      cd = "z";
    };
  };

  programs.eza = {
    enable = true;
    colors = "always";
    enableFishIntegration = false;
    extraOptions = [
      "-lah"
      "--group-directories-first"
    ];
  };

  programs.fd.enable = true;
  programs.fzf.enable = true;
  programs.ripgrep.enable = true;
  programs.zoxide.enable = true;

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "james7132";
        email = "contact@no-bull.sh";
        signingkey = "/home/james/.ssh/id_ed25519_nobullsh.pub";
      };
      init = {
        defaultBranch = "main";
      };
      commit = {
        gpgsign = true;
      };
      push = {
        default = "simple";
      };
      pull = {
        rebase = true;
      };
      gpg = {
        format = "ssh";
      };
    };
  };

  programs.tmux = {
    enable = true;
    # 0 is too far
    baseIndex = 1;
    prefix = "C-a";
    shell = "${pkgs.fish}/bin/fish";
    keyMode = "vi";
    extraConfig = ''
      # Smart pane switching with awareness of Vim splits.
      # See: https://github.com/christoomey/vim-tmux-navigator
      vim_pattern='(\S+/)?g?\.?(view|l?n?vim?x?|fzf)(diff)?(-wrapped)?'
      is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
          | grep -iqE '^[^TXZ ]+ +'$${vim_pattern}$'"
      bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h'  'select-pane -L'
      bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j'  'select-pane -D'
      bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k'  'select-pane -U'
      bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l'  'select-pane -R'
      tmux_version='$(tmux -V | sed -En "s/^tmux ([0-9]+(.[0-9]+)?).*/\1/p")'
      if-shell -b '[ "$(echo "$tmux_version < 3.0" | bc)" = 1 ]' \
          "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\'  'select-pane -l'"
      if-shell -b '[ "$(echo "$tmux_version >= 3.0" | bc)" = 1 ]' \
          "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\\\'  'select-pane -l'"

      bind-key -T copy-mode-vi 'C-h' select-pane -L
      bind-key -T copy-mode-vi 'C-j' select-pane -D
      bind-key -T copy-mode-vi 'C-k' select-pane -U
      bind-key -T copy-mode-vi 'C-l' select-pane -R
      bind-key -T copy-mode-vi 'C-\' select-pane -l

      ## Status bar design
      # status line
      set -g status-justify left
      set -g status-bg default
      set -g status-fg colour12
      set -g status-interval 2

      # window status
      setw -g window-status-format " #F#I:#W#F "
      setw -g window-status-current-format " #F#I:#W#F "
      setw -g window-status-format "#[fg=magenta]#[bg=black] #I #[bg=cyan]#[fg=colour8] #W "
      setw -g window-status-current-format "#[bg=brightmagenta]#[fg=colour8] #I #[fg=colour8]#[bg=colour14] #W "

      # Info on left (I don't have a session display for now)
      set -g status-left ''''''

      # loud or quiet?
      set-option -g visual-activity off
      set-option -g visual-bell off
      set-option -g visual-silence off
      set-window-option -g monitor-activity off
      set-option -g bell-action none

      set -g default-terminal "screen-256color"

      # The modes {
      setw -g clock-mode-colour colour135
      # }
      # The statusbar {
      set -g status-position bottom
      set -g status-bg colour234
      set -g status-fg colour137
      set -g status-left ''''''
      set -g status-right '#[fg=colour233,bg=colour241,bold] %d/%m #[fg=colour233,bg=colour245,bold] %H:%M:%S '
      set -g status-right-length 50
      set -g status-left-length 20

      setw -g window-status-current-format ' #I#[fg=colour250]:#[fg=colour255]#W#[fg=colour50]#F '

      setw -g window-status-format ' #I#[fg=colour237]:#[fg=colour250]#W#[fg=colour244]#F '
      # }
    '';
  };

  programs.helix = {
    enable = true;
    defaultEditor = true;
    settings = {
      theme = "monokai";
      editor = {
        mouse = false;
        true-color = true;
        color-modes = true;
        line-number = "relative";
        bufferline = "multiple";
        cursor-shape.insert = "bar";
      };

      keys.normal = {
        ";" = "command_mode";
        "esc" = [
          "collapse_selection"
          "keep_primary_selection"
        ];
        "H" = [ "extend_to_first_nonwhitespace" ];
        "L" = [ "extend_to_line_end" ];
        "D" = [
          "extend_to_line_end"
          "delete_selection"
        ];
        "C" = [
          "extend_to_line_end"
          "delete_selection"
          "insert_mode"
        ];
        "N" = [
          "search_prev"
          "align_view_center"
        ];
        "n" = [
          "search_next"
          "align_view_center"
        ];
      };
    };
    languages = {
      language-server.rust-analyzer.config.check.command = "clippy";
      language = [
        {
          name = "rust";
          formatter.command = "rustfmt";
          auto-format = true;
        }
        {
          name = "rust";
          formatter = {
            command = "taplo";
            args = [
              "fmt"
              "-"
            ];
          };
          auto-format = true;
        }
        {
          name = "nix";
          formatter.command = "nixfmt";
          auto-format = true;
        }
      ];
    };
  };

}
