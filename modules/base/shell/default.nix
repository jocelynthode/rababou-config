{
  programs = {
    fish = {
      enable = true;
      vendor = {
        completions.enable = true;
        config.enable = true;
        functions.enable = true;
      };
    };
    zsh = {
      enable = true;
      enableCompletion = true;
    };
  };
}
