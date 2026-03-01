{
  config,
  lib,
  pkgs,
  ...
}:
{
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
      cd = "z";
    };
  };

  programs.eza = {
    enable = true;
    colors = "always";
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

  programs.fuzzel = {
    # enable = config.hardware.graphics.enable;
    enable = true;
    settings = {
      main = {
        terminal = "foot -e";
      };
      colors = {
        background = "222222aa";
        text = "ddddddff";
        match = "005588ff";
        selection = "555555ff";
        selection-text = "ffffffff";
        selection-match = "33aaffff";
        border = "ffffffaa";
      };
      border = {
        width = 2;
        radius = 10;
      };
    };
  };

  programs.foot = {
    # enable = config.hardware.graphics.enable;
    enable = true;
    settings = {
      main = {
        font = "monospace:size=18";
      };
      colors = {
        alpha = 0.75;
        background = "242424";
        foreground = "ffffff";
      };
      url = {
        launch = "/usr/bin/env handlr open {url}";
      };
    };
  };

  services.mako = {
    # enable = config.programs.niri.enable;
    enable = true;
    settings = {
      width = 500;
      background-color = "#333333";
      border-color = "#AAAAAA";
      border-radius = 20;
    };
  };

  programs.swaylock = {
    # enable = config.programs.niri.enable;
    enable = true;
    settings = {
      color = "#000000";
    };
  };

  programs.vesktop = {
    enable = true;
    settings = {
      discordBranch = "stable";
      minimizeToTray = true;
      arRPC = false;
      splashColor = "rgb(220, 220, 223)";
      splashBackground = "rgb(0, 0, 0)";
      spellCheckLanguages = [
        "en-US"
        "en"
      ];
    };
    vencord.settings = {
      autoUpdate = true;
      autoUpdateNotification = true;
      useQuickCss = true;
      themeLinks = [ ];
      eagerPatches = false;
      enabledThemes = [ ];
      enableReactDevtools = false;
      frameless = true;
      transparent = false;
      winCtrlQ = false;
      disableMinSize = false;
      winNativeTitleBar = false;
      plugins = {
        ChatInputButtonAPI = {
          enabled = false;
        };
        CommandsAPI = {
          enabled = true;
        };
        DynamicImageModalAPI = {
          enabled = false;
        };
        MemberListDecoratorsAPI = {
          enabled = false;
        };
        MessageAccessoriesAPI = {
          enabled = true;
        };
        MessageDecorationsAPI = {
          enabled = false;
        };
        MessageEventsAPI = {
          enabled = false;
        };
        MessagePopoverAPI = {
          enabled = false;
        };
        MessageUpdaterAPI = {
          enabled = false;
        };
        ServerListAPI = {
          enabled = false;
        };
        UserSettingsAPI = {
          enabled = true;
        };
        AccountPanelServerProfile = {
          enabled = false;
        };
        AlwaysAnimate = {
          enabled = false;
        };
        AlwaysExpandRoles = {
          enabled = true;
        };
        AlwaysTrust = {
          enabled = true;
          domain = true;
          file = true;
        };
        AnonymiseFileNames = {
          enabled = true;
        };
        AppleMusicRichPresence = {
          enabled = false;
        };
        "WebRichPresence (arRPC)" = {
          enabled = false;
        };
        BetterFolders = {
          enabled = false;
        };
        BetterGifAltText = {
          enabled = false;
        };
        BetterGifPicker = {
          enabled = false;
        };
        BetterNotesBox = {
          enabled = false;
        };
        BetterRoleContext = {
          enabled = false;
        };
        BetterRoleDot = {
          enabled = false;
        };
        BetterSessions = {
          enabled = false;
        };
        BetterSettings = {
          enabled = false;
        };
        BetterUploadButton = {
          enabled = false;
        };
        BiggerStreamPreview = {
          enabled = false;
        };
        BlurNSFW = {
          enabled = false;
        };
        CallTimer = {
          enabled = false;
        };
        ClearURLs = {
          enabled = false;
        };
        ClientTheme = {
          enabled = false;
        };
        ColorSighted = {
          enabled = true;
        };
        ConsoleJanitor = {
          enabled = false;
        };
        ConsoleShortcuts = {
          enabled = false;
        };
        CopyEmojiMarkdown = {
          enabled = false;
        };
        CopyFileContents = {
          enabled = false;
        };
        CopyStickerLinks = {
          enabled = false;
        };
        CopyUserURLs = {
          enabled = false;
        };
        CrashHandler = {
          enabled = true;
        };
        CtrlEnterSend = {
          enabled = false;
        };
        CustomIdle = {
          enabled = false;
        };
        CustomRPC = {
          enabled = false;
        };
        Dearrow = {
          enabled = true;
          hideButton = false;
          replaceElements = 0;
          dearrowByDefault = true;
        };
        Decor = {
          enabled = false;
        };
        DisableCallIdle = {
          enabled = false;
        };
        DontRoundMyTimestamps = {
          enabled = false;
        };
        Experiments = {
          enabled = false;
        };
        ExpressionCloner = {
          enabled = false;
        };
        F8Break = {
          enabled = false;
        };
        FakeNitro = {
          enabled = false;
        };
        FakeProfileThemes = {
          enabled = false;
        };
        FavoriteEmojiFirst = {
          enabled = false;
        };
        FavoriteGifSearch = {
          enabled = false;
        };
        FixCodeblockGap = {
          enabled = false;
        };
        FixImagesQuality = {
          enabled = false;
        };
        FixSpotifyEmbeds = {
          enabled = false;
        };
        FixYoutubeEmbeds = {
          enabled = true;
        };
        ForceOwnerCrown = {
          enabled = false;
        };
        FriendInvites = {
          enabled = false;
        };
        FriendsSince = {
          enabled = false;
        };
        FullSearchContext = {
          enabled = false;
        };
        FullUserInChatbox = {
          enabled = false;
        };
        GameActivityToggle = {
          enabled = false;
        };
        GifPaste = {
          enabled = false;
        };
        GreetStickerPicker = {
          enabled = false;
        };
        HideMedia = {
          enabled = false;
        };
        iLoveSpam = {
          enabled = false;
        };
        IgnoreActivities = {
          enabled = false;
        };
        ImageFilename = {
          enabled = false;
        };
        ImageLink = {
          enabled = true;
        };
        ImageZoom = {
          enabled = false;
        };
        ImplicitRelationships = {
          enabled = false;
        };
        IrcColors = {
          enabled = false;
        };
        KeepCurrentChannel = {
          enabled = false;
        };
        LastFMRichPresence = {
          enabled = false;
        };
        LoadingQuotes = {
          enabled = false;
        };
        MemberCount = {
          enabled = false;
        };
        MentionAvatars = {
          enabled = false;
        };
        MessageClickActions = {
          enabled = false;
        };
        MessageLatency = {
          enabled = false;
        };
        MessageLinkEmbeds = {
          enabled = false;
        };
        MessageLogger = {
          enabled = false;
        };
        MessageTags = {
          enabled = false;
        };
        MoreQuickReactions = {
          enabled = false;
        };
        MutualGroupDMs = {
          enabled = false;
        };
        NewGuildSettings = {
          enabled = false;
        };
        NoBlockedMessages = {
          enabled = false;
        };
        NoDevtoolsWarning = {
          enabled = false;
        };
        NoF1 = {
          enabled = false;
        };
        NoMaskedUrlPaste = {
          enabled = false;
        };
        NoMosaic = {
          enabled = false;
        };
        NoOnboardingDelay = {
          enabled = false;
        };
        NoPendingCount = {
          enabled = false;
        };
        NoProfileThemes = {
          enabled = false;
        };
        NoReplyMention = {
          enabled = false;
        };
        NoServerEmojis = {
          enabled = false;
        };
        NoTypingAnimation = {
          enabled = false;
        };
        NoUnblockToJump = {
          enabled = false;
        };
        NormalizeMessageLinks = {
          enabled = false;
        };
        NotificationVolume = {
          enabled = false;
        };
        OnePingPerDM = {
          enabled = true;
        };
        oneko = {
          enabled = false;
        };
        OpenInApp = {
          enabled = false;
        };
        OverrideForumDefaults = {
          enabled = false;
        };
        PauseInvitesForever = {
          enabled = false;
        };
        PermissionFreeWill = {
          enabled = false;
        };
        PermissionsViewer = {
          enabled = false;
        };
        petpet = {
          enabled = false;
        };
        PictureInPicture = {
          enabled = false;
        };
        PinDMs = {
          enabled = false;
        };
        PlainFolderIcon = {
          enabled = false;
        };
        PlatformIndicators = {
          enabled = false;
        };
        PreviewMessage = {
          enabled = false;
        };
        QuickMention = {
          enabled = false;
        };
        QuickReply = {
          enabled = false;
        };
        ReactErrorDecoder = {
          enabled = false;
        };
        ReadAllNotificationsButton = {
          enabled = false;
        };
        RelationshipNotifier = {
          enabled = false;
        };
        ReplaceGoogleSearch = {
          enabled = true;
        };
        ReplyTimestamp = {
          enabled = false;
        };
        RevealAllSpoilers = {
          enabled = false;
        };
        ReverseImageSearch = {
          enabled = false;
        };
        ReviewDB = {
          enabled = false;
        };
        RoleColorEverywhere = {
          enabled = false;
        };
        SecretRingToneEnabler = {
          enabled = false;
        };
        Summaries = {
          enabled = false;
        };
        SendTimestamps = {
          enabled = false;
        };
        ServerInfo = {
          enabled = false;
        };
        ServerListIndicators = {
          enabled = false;
        };
        ShikiCodeblocks = {
          enabled = false;
        };
        ShowAllMessageButtons = {
          enabled = false;
        };
        ShowConnections = {
          enabled = false;
        };
        ShowHiddenChannels = {
          enabled = true;
          showMode = 0;
          hideUnreads = true;
        };
        ShowHiddenThings = {
          enabled = false;
        };
        ShowMeYourName = {
          enabled = false;
        };
        ShowTimeoutDuration = {
          enabled = false;
        };
        SilentMessageToggle = {
          enabled = false;
        };
        SilentTyping = {
          enabled = false;
        };
        SortFriendRequests = {
          enabled = false;
        };
        SpotifyControls = {
          enabled = false;
        };
        SpotifyCrack = {
          enabled = false;
        };
        SpotifyShareCommands = {
          enabled = false;
        };
        StartupTimings = {
          enabled = false;
        };
        StickerPaste = {
          enabled = false;
        };
        StreamerModeOnStream = {
          enabled = false;
        };
        SuperReactionTweaks = {
          enabled = false;
        };
        TextReplace = {
          enabled = false;
        };
        ThemeAttributes = {
          enabled = false;
        };
        Translate = {
          enabled = false;
        };
        TypingIndicator = {
          enabled = false;
        };
        TypingTweaks = {
          enabled = false;
        };
        Unindent = {
          enabled = false;
        };
        UnlockedAvatarZoom = {
          enabled = false;
        };
        UnsuppressEmbeds = {
          enabled = false;
        };
        UserMessagesPronouns = {
          enabled = false;
        };
        UserVoiceShow = {
          enabled = false;
        };
        USRBG = {
          enabled = false;
        };
        ValidReply = {
          enabled = false;
        };
        ValidUser = {
          enabled = false;
        };
        VoiceChatDoubleClick = {
          enabled = false;
        };
        VcNarrator = {
          enabled = false;
        };
        VencordToolbox = {
          enabled = false;
        };
        ViewIcons = {
          enabled = false;
        };
        ViewRaw = {
          enabled = false;
        };
        VoiceDownload = {
          enabled = false;
        };
        VoiceMessages = {
          enabled = false;
        };
        VolumeBooster = {
          enabled = false;
        };
        WebKeybinds = {
          enabled = true;
        };
        WebScreenShareFixes = {
          enabled = true;
        };
        WhoReacted = {
          enabled = false;
        };
        XSOverlay = {
          enabled = false;
        };
        YoutubeAdblock = {
          enabled = true;
        };
        BadgeAPI = {
          enabled = true;
        };
        NoTrack = {
          enabled = true;
          disableAnalytics = true;
        };
        Settings = {
          enabled = true;
          settingsLocation = "aboveNitro";
        };
        DisableDeepLinks = {
          enabled = true;
        };
        SupportHelper = {
          enabled = true;
        };
        WebContextMenus = {
          enabled = true;
        };
      };
      uiElements = {
        chatBarButtons = { };
        messagePopoverButtons = { };
      };
      notifications = {
        timeout = 5000;
        position = "bottom-right";
        useNative = "not-focused";
        logLimit = 50;
      };
      cloud = {
        authenticated = false;
        url = "https://api.vencord.dev/";
        settingsSync = false;
      };
    };

  };

  programs.librewolf = {
    # enabled = config.hardware.graphics.enable;
    enable = false;
    settings = {
      "privacy.resistFingerprinting.letterboxing" = true;

      "browser.toolbars.bookmarks.visibility" = "never";

      "sidebar.revamp" = true;
      "sidebar.verticalTabs" = true;
      "sidebar.verticalTabs.dragToPinPromo.dismissed" = true;
      "sidebar.visibility" = "expand-on-hover";
      "sidebar.position_start" = false;
    };
  };
}
