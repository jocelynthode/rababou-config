{
  home-manager.users.simon = {
    home.sessionVariables = {
      EDITOR = "vim";
      VISUAL = "vim";
    };

    programs = {
      atuin = {
        enable = true;
        flags = [
          "--disable-up-arrow"
        ];
        settings = {
          enter_accept = false;
          exit_mode = "return-query";
          inline_height = 0;
          search_mode = "fulltext";
        };
      };
      fd.enable = true;
      fzf = {
        enable = true;
      };
      jq.enable = true;
      ripgrep.enable = true;
      vim.enable = true;
      zsh = {
        enable = true;
        oh-my-zsh = {
          enable = true;
          plugins = [
            "common-aliases"
            "dirpersist"
            "git"
            "perms"
            "sudo"
            "systemd"
            "virtualenv"
            "wd"
          ];
          theme = "bira";
          extraConfig = ''
            COMPLETION_WAITING_DOTS="true";
          '';
        };
        initContent = ''
          ## Use behavior similar to bash for CTRL+W ##
          autoload -U backward-kill-word-match
          # Define a new 'backward-kill-space-word' widget and apply "shell" style.
          # The 'shell' style is similar to bash, except that it also matches escaped whitespace
          zle -N backward-kill-space-word backward-kill-word-match
          zstyle :zle:backward-kill-space-word word-style shell
          bindkey '^W' backward-kill-space-word
        '';
      };
    };
  };
}
