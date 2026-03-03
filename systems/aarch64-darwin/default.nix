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
    };

    finder = {
      AppleShowAllExtensions = true;
      ShowPathbar = true;
    };
  };
}
