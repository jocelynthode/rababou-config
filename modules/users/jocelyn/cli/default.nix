{
  home-manager.users.jocelyn = {
    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      PAGER = "bat";
    };

    programs = {
      bat = {
        enable = true;
      };
      fd.enable = true;
      fzf = {
        enable = true;
      };
      lsd = {
        enable = true;
        enableFishIntegration = true;
        settings = {
          symlink-arrow = "⇒";
        };
      };
      ripgrep.enable = true;
      zoxide = {
        enable = true;
        options = [ "--cmd cd" ];
      };
      jq.enable = true;
      atuin = {
        enable = true;
        settings = {
          keymap_mode = "auto";
          search_mode = "fuzzy";
        };
      };
    };
  };
}
