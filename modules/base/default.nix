{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./cli
    ./filesystems
    ./shell
    ./network
    ./nix
    ./sshd
    ./sudo
  ];

  options.aspects = {
    stateVersion = lib.mkOption {
      example = "25.11";
    };

    allowReboot = lib.mkEnableOption "allowReboot";
  };

  config = lib.mkMerge [
    {
      home-manager = {
        useGlobalPkgs = true;
      };

      system = {
        inherit (config.aspects) stateVersion;
        autoUpgrade = {
          enable = true;
          flake = "github:jocelynthode/rababou-config";
          dates = "Sat *-*-* 03:00:00";
          randomizedDelaySec = "10min";
          inherit (config.aspects) allowReboot;
          rebootWindow = {
            lower = "03:00";
            upper = "05:00";
          };
        };
      };

      home-manager.users = {
        jocelyn = _: {
          home.stateVersion = config.aspects.stateVersion;
          systemd.user.sessionVariables = config.home-manager.users.jocelyn.home.sessionVariables;
        };
        simon = _: {
          home.stateVersion = config.aspects.stateVersion;
          systemd.user.sessionVariables = config.home-manager.users.simon.home.sessionVariables;
        };
        root = _: {
          home.stateVersion = config.aspects.stateVersion;
        };
      };

      environment = {
        enableAllTerminfo = true;
        systemPackages = with pkgs; [
          git
          killall
          wget
          curl
          python3
          any-nix-shell
          moreutils
          ldns
          gnumake
          gettext
          procps
          lsof
          rsync
          unzip
          net-tools
        ];
      };

      i18n = {
        defaultLocale = "en_US.UTF-8";
        extraLocaleSettings = {
          LC_TIME = "fr_CH.UTF-8";
          LC_MONETARY = "fr_CH.UTF-8";
          LC_MEASUREMENT = "fr_CH.UTF-8";
          LC_COLLATE = "fr_CH.UTF-8";
        };
      };
      time.timeZone = "Europe/Zurich";

      users = {
        mutableUsers = false;
        users = {
          jocelyn = {
            isNormalUser = true;
            shell = pkgs.fish;
            # with mkpasswd
            initialHashedPassword = "$y$j9T$9iCmcMnLeZI60zhGSqSnB0$vkNq4vBlT9pYociW2ziGbr77LQWrYXTsGqtk/yuQ61/";
            autoSubUidGidRange = true;
            extraGroups = [
              "wheel"
            ];
            openssh.authorizedKeys.keys = [
              "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDt+7HTCLF1Q658UrgvVb4a47Jp3aJt8mBY4dWltoHXUqXFkgfU7Y1zoDyEtylXRaqqSi4sWwW2WDT6wmzSx5DPf7y8sj9gSSpCSMoDOXlO2ylZdWdShpgXRJ4DZ0zlM0oWk5iNb+OdWLRluu7K1IYJZe5wMl8+fDsdXLg29xep8CwpjYAFtgPREImS5r5whMHLsUHQ19u0p3cGN2tvh9SW9otCL2rcCWz2KV09/VKWCzc6x5eVnsZtvw9VSmBrpnlt/DgXTqgCeg3L6smRSlyslQzswxhEesMpp+JJRdSD2wcWDZGoVsR9Yhbk9tOOZ3s79k5w2XVTqzYQnLagAS2YkSgS1+0+Wi4G+lqZ8ypEo0hzSpI4HcNxlRXGSAykkvp+TqkAsoOXd/0PauB6N24TBpfi2VDF/EDWSviyhJwD2KU8mLqXya57HwheDX/e35TNpYUwavN1Nf4FXZ/VdN+13mlAbQSkDQRa+bn/HeZGRZTwXmV0Vl0BAS0m8wWNJ223HJTiEVLuJuPMS9xLSvredULISh/9hXW7Ma86bVHA69lK7To8EFZGLZhXb5QH4sJeekPMdsuuioitHb5a0TploRzBrFCqmBM7N85uyBt4gXjMkYpf/kGtGiOAV4k8n9mFDyoCl1MvnP3JlUzRhMJ41Rz4tgCPHZ7s3Hq9lkU3Vw== jocelyn@yubikey"
            ];
          };
          simon = {
            isNormalUser = true;
            shell = pkgs.zsh;
            initialHashedPassword = "$y$j9T$awnHBpb829f9oIBoQvq6e.$j4kjyiJNaYYEodMEl/jZBqWOg/ujTeyP1uk1Gp/sN14";
            extraGroups = [
              "wheel"
            ];
            openssh.authorizedKeys.keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPz9TNeNHnhk6duNRqNbY6KoWnRXmA1xsNz/4EB+MwC0 simon2023"
            ];
          };
          root = {
            home = "/root";
          };
        };
      };
    }
  ];
}
