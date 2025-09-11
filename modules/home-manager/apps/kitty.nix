# ./modules/home-manager/apps/kitty.nix

{ config, lib, ... }: {
  programs.kitty = {
    enable = true;

    # Apply a Kitty color theme. This option takes the file name of a theme in 
    # kitty-themes, without the .conf suffix. 
    # See https://github.com/kovidgoyal/kitty-themes/tree/master/themes for a list of
    # themes.
    themeFile = "OneDark";

    enableGitIntegration = true;

    # Specific settings
    settings = {
      confirm_os_window_close = 0;
      enable_audio_bell = false;
      window_padding_width = 4;
    };
  };
}