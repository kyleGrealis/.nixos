{ config, pkgs, ... }:

{

  imports = [
    ./modules/home-manager
  ];

  home.username = "kyle";
  home.homeDirectory = "/home/kyle";
  home.stateVersion = "25.05";
  home.packages = [];
  home.file = {};

  home.sessionVariables = {
    HISTCONTROL = "ignoreboth:erasedups";
    HISTSIZE = "10000";
    HISTFILESIZE = "10000";
    NVM_DIR = "$HOME/.nvm";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # -------- End of Default File! -------- #

  # Override warning message -- added 9.03.2025:
  home.enableNixpkgsReleaseCheck = false; 

  # bash
  programs.bash = {
    enable = true;
    enableCompletion = true;
    historyControl = [ "ignoreboth" "erasedups" ];
    historySize = 10000;
    historyFileSize = 10000;

    shellOptions = [
      "histappend"
      "checkwinsize"
    ];

    shellAliases = {
      # git aliases
      ga = "git add";
      gc = "git commit -m";
      gd = "git diff -U0";
      gst = "git status";
      gpull = "git pull";
      gpush = "git push";

      # ls aliases
      ls = "ls -alh --color=auto";
      ll = "ls -alF";
      la = "ls -A";
      l = "ls -CF";
      
      # misc
      # code = "positron";
      now = "date +%F\\ %T";
      rsync = "rsync -azH --info=progress2";
      weather = "curl wttr.in/Dallas?0";
      grep = "grep --color=auto";
      fgrep = "fgrep --color=auto";
      egrep = "egrep --color=auto";
      
      # alert for long running commands
      alert = "notify-send --urgency=low -i \"$([ $? = 0 ] && echo terminal || echo error)\" \"$(history|tail -n1|sed -e '\\''s/^\\s*[0-9]\\+\\s*//;s/[;&|]\\s*alert$//'\\'')\"";
    };

    bashrcExtra = ''
      # Color definitions
      export purple='\033[0;35m'       # Purple
      export bgreen='\033[1;32m'       # Bold Green
      export bblue='\033[1;34m'        # Bold Blue

      # Change directory AND list contents of the directory
      cdl() {
        cd "$@";
        ls -alh;
      }

      # Launch Positron
      code() {
        nohup positron "$@" >/dev/null 2>&1 & disown
      }


      # This function takes in a list of files and a commit message
      # Example: gam . 'initial commit'
      gam() {
        for file in "''${@:1:$#-1}"; do
          git add "$file"
        done
        git commit -m "''${!#}"
      }

      # Restart terminal session
      restart() {
        source "$HOME/.bashrc" 2>/dev/null || source "$HOME/.bashrc"
      }
      
      # Git branch parsing for prompt
      parse_git_branch() {
        git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
      }

      # Watch the tailnet log in live time as autoswitching occurs
      taillog () { tail -f /var/log/tailscale-autoswitch.log; }
      
      # Custom prompt - recreating your original
      PS1='\n\[\033[1;34m\]\W\[\033[0;35m\]$(parse_git_branch) \[\033[0m\]\n\[\033[0;32m\]\u@\h\[\033[0m\] >> '
      
      # Add ~/.local/bin to PATH if it exists
      if [ -d "$HOME/.local/bin" ] ; then
          PATH="$HOME/.local/bin:$PATH"
      fi
      
      # Remove duplicates from PATH
      PATH=$(echo $PATH | tr ':' '\n' | awk '!seen[$0]++' | tr '\n' ':' | sed 's/:$//')
      export PATH
      
      # Load NVM if available
      [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
      [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
      
      # Enable dircolors if available
      if [ -x /usr/bin/dircolors ]; then
          test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
      fi

      # Remove ugly background highlights on some directories
      export LS_COLORS="''${LS_COLORS}:ow=01;34"
    '';
  };

  # .Rprofile
  home.file.".Rprofile".text = ''
    if (interactive()) {
      suppressMessages(require(devtools))
      suppressMessages(require(tidyverse))
    }

    # set the default CRAN mirror
    local({
      r <- getOption("repos")
      r["CRAN"] <- "https://cran.rstudio.com/"
      options(repos = r)
    })

    options(
      prompt = ">> ",
      shiny.port = 7209,
      digits = 4
    )

    options(
      usethis.full_name = 'Kyle Grealis',
      usethis.description = list(
        `Authors@R` = 'person(
          given = "Kyle",
          family = "Grealis",
          role = c("aut", "cre"),
          email = "kyle@kyleGrealis.com",
          comment = c(ORCID = "0000-0002-9223-8854")
        )'
      )
    )
  '';

  # git
  home.file.".gitconfig".text = ''
    [init]
      defaultBranch = main
    [user]
      name = Kyle Grealis
      email = kyle@kyleGrealis.com
    [credential]
      helper = cache
    [core]
      excludesFile = ~/.gitignore
      autocrlf = false
  '';
  
}
