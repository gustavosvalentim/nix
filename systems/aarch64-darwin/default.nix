{ ... }:

{
  imports = [
    ./homebrew.nix
  ];

  system.defaults = {
    dock = {
      autohide = true;
      show-recents = false;
      orientation = "bottom";
      tilesize = 42;
    };

    finder = {
      AppleShowAllExtensions = true;
      ShowPathbar = true;
    };
  };
}
