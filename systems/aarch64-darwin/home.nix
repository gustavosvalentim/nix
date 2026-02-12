{ pkgs, lib, username, ... }:

{
  # this is internal compatibility configuration 
  # for home-manager, don't change this!
  home.stateVersion = "23.05";

  # Disabled for now since we mismatch our versions. See flake.nix for details.
  home.enableNixpkgsReleaseCheck = false;

  xdg.enable = true;

  home.sessionVariables = {
    EDITOR = "nvim";
    PATH   = "$\{ASDF_DATA_DIR:-$HOME/.asdf\}/shims:$PATH";
    OPENCODE_CONFIG = "$HOME/.config/opencode/opencode.jsonc";
  };

  home.packages = let
    packages = import ../../common/packages.nix { inherit pkgs username; };
    in packages.darwinPackages;

  fonts.fontconfig.enable = true;

  home.activation.cloneNeovimConfig = lib.hm.dag.entryAfter [ "writeBoundary" "installPackages" "programs.git" ] ''
    echo "Running post-rebuild script" >> /tmp/nix-darwin-activation.log
    REPOSITORY="https://github.com/gustavosvalentim/nvim"
    DIRECTORY="$HOME/.config/nvim"
    if [ ! -d "$DIRECTORY" ]; then
      ${pkgs.git}/bin/git clone "$REPOSITORY" "$DIRECTORY" 
    fi
  '';

  home.file."ghostty-config" = {
    target = "/Users/${username}/Library/Application\ Support/com.mitchellh.ghostty/config";
    source = ../../common/ghostty/config;
  };

  # Workaround for muting ghostty when resizing split windows
  # https://github.com/ghostty-org/ghostty/discussions/5521#discussioncomment-12306028
  home.file."macos-default-keybinding" = {
    target = "/Users/${username}/Library/KeyBindings/DefaultKeyBinding.dict";
    source = ../../common/macos/DefaultKeyBinding.dict;
  };

  home.file."opencode-agent-md" = {
    target = "/Users/${username}/.config/opencode/AGENTS.md";
    source = ../../common/opencode/AGENTS.md;
    force = true;
  };

  home.file."opencode-config" = {
    target = "/Users/${username}/.config/opencode/opencode.jsonc";
    source = ../../common/opencode/opencode.jsonc;
  };

  # home.file."oh-my-opencode-config" = {
  #   target = "/Users/${username}/.config/opencode/oh-my-opencode.json";
  #   source = ../../common/opencode/oh-my-opencode.json;
  #   force = true;
  # };

  # Install oh-my-opencode
  # home.activation.installOhMyOpenCode = lib.hm.dag.entryAfter [ "writeBoundary" "installPackages" "programs.git" ] ''
  # home.activation.installOhMyOpenCode = lib.hm.dag.entryBefore [ "writeBoundary" ] ''
  #   export PATH="/opt/homebrew/bin:$PATH"
  #   if [ ! -f "$HOME/.config/opencode/opencode.jsonc" ] \
  #     && command -v opencode >/dev/null 2>&1 \
  #     && command -v bunx >/dev/null 2>&1; then
  #     bunx oh-my-opencode install --no-tui --claude=no --openai=no --gemini=no --copilot=no
  #   fi
  # '';

  programs =
    let packages = import ../../common/packages.nix { inherit pkgs username; };
    in packages.programs;
}
