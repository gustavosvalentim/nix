{ ... }:

{
  imports = [
    ./homebrew.nix
  ];

  system.defaults = {
    dock = {
      autohide = true;
      show-recents = false;
      orientation = "left";
    };

    finder = {
      AppleShowAllExtensions = true;
      ShowPathbar = true;
    };
  };
}
