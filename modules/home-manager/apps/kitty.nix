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

      #---------- One Dark theme ----------#
      # foreground #979eab
      # background #282c34
      # selection_foreground #282c34
      # selection_background #979eab

      # cursor #cccccc
      # color0 #282c34
      # color1 #e06c75
      # color2 #98c379
      # color3 #e5c07b
      # color4 #61afef
      # color5 #be5046
      # color6 #56b6c2
      # color7 #979eab
      # color8 #393e48
      # color9 #d19a66
      # color10 #56b6c2
      # color11 #e5c07b
      # color12 #61afef
      # color13 #be5046
      # color14 #56b6c2
      # color15 #abb2bf

      # cursor = "#abb2bf";
      # url_color = "#61afef";
      #-----------------------------------#
    };
  };
}