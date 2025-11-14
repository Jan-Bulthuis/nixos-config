{
  lib,
  config,
  pkgs,
  ...
}:

{
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    # Desktop environment
    gnome-text-editor
    gnome-calculator
    gnome-console
    gnome-logs
    gnome-system-monitor
    nautilus
    adwaita-icon-theme
    gnome-control-center
    gnome-shell-extensions
    glib
    gnome-menus
    gtk3.out
    xdg-user-dirs
    xdg-user-dirs-gtk
    cantarell-fonts
    dejavu_fonts
    source-code-pro
    source-sans
    gnome-session
    adwaita-fonts

    # Coding tools
    vim-full
    nano
    neovim
    emacs
    gedit
    geany
    kdePackages.kate
    vscode
    python310
    jdk17
    gnumake
    gcc
    lldb
    # pypy310

    # Runners
    (writeShellScriptBin "mygcc" "gcc -std=gnu17 -x c -Wall -O2 -static -pipe -o $1 \"$1.c\" -lm")
    (writeShellScriptBin "mygpp" "g++ -std=gnu++20 -x c++ -Wall -O2 -static -pipe -o $1 \"$1.cpp\" -lm")
    (writeShellScriptBin "mypython" "python3 $@")
    (writeShellScriptBin "myjavac" "javac -encoding UTF-8 -sourcepath . -d . $@")
    (writeShellScriptBin "mykotlinc" "kotlinc -d . $@")
  ];

  modules.profiles.gnome.enable = true;

  programs.vscode = {
    enable = true;
    mutableExtensionsDir = false;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        ms-vscode.cpptools
        ms-dotnettools.csharp
        formulahendry.code-runner
        vscjava.vscode-java-debug
        dbaeumer.vscode-eslint
        redhat.java
        ms-python.python
      ];
    };
  };

  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
    profiles.default = {
      settings = {
        "browser.startup.homepage" = "https://domjudge.bulthuis.dev";
      };
      bookmarks = {
        force = true;
        settings = [
          {
            name = "Sites";
            toolbar = true;
            bookmarks = [
              {
                name = "C Reference";
                url = "https://en.cppreference.com/w/c";
              }
              {
                name = "C++ Reference";
                url = "https://en.cppreference.com/w/cpp";
              }
              {
                name = "Python 3.10 documentation";
                url = "https://docs.python.org/3.10/download.html";
              }
              {
                name = "Java 17 API Specification";
                url = "https://docs.oracle.com/en/java/javase/17/docs/api/";
              }
              {
                name = "Kotlin Language Documentation";
                url = "https://kotlinlang.org/docs/kotlin-reference.pdf";
              }
              {
                name = "DOMjudge Team Manual";
                url = "https://www.domjudge.org/docs/manual/main/index.html";
              }
            ];
          }
        ];
      };
    };
  };
}
