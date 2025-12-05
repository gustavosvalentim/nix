# nix-darwin Configuration

Personal macOS system configuration using [nix-darwin](https://github.com/nix-darwin/nix-darwin) and [home-manager](https://github.com/nix-community/home-manager). This repository manages system packages, user environment, dotfiles, and macOS settings declaratively.

## What This Configuration Does

This configuration sets up a complete development environment on macOS including:

- **System Configuration** (via nix-darwin):
  - Homebrew integration with specified brews and casks
  - Touch ID authentication for sudo
  - Experimental Nix features (flakes, nix-command)

- **User Environment** (via home-manager):
  - Development tools: Go, Node.js, Neovim, Git, GitHub CLI
  - CLI utilities: bat, ripgrep, tree, fzf, jq, uv, claude-code
  - Zsh with Oh-My-Zsh configuration
  - Git configuration and aliases
  - Automatic Neovim configuration cloning

- **Managed Applications**:
  - Homebrew Casks: OrbStack, Keeper Password Manager, Zen Browser
  - Homebrew Brews: cowsay, asdf

## Prerequisites

### Install Nix

Install the [Determinate Systems Nix Installer](https://github.com/DeterminateSystems/nix-installer) with the `--prefer-upstream-nix` flag to use the vanilla upstream Nix distribution:

```bash
curl -fsSL https://install.determinate.systems/nix | sh -s -- install --prefer-upstream-nix
```

> **Note**: The `--prefer-upstream-nix` flag installs the official NixOS Nix implementation instead of Determinate's fork. Without this flag, you would need to add `nix.enable = false;` to your nix-darwin configuration.

### Install nix-darwin

Once Nix is installed, you can install nix-darwin. Since this repository already contains a flake configuration, you can either:

1. **Clone this repository** (if you want to use this exact configuration):
   ```bash
   git clone https://github.com/gustavosvalentim/nix ~/.config/nix
   cd ~/.config/nix
   ```

2. **Or start from scratch** (if you want to create your own):
   ```bash
   sudo mkdir -p /etc/nix-darwin
   sudo chown $(id -nu):$(id -ng) /etc/nix-darwin
   cd /etc/nix-darwin
   nix flake init -t nix-darwin/master
   sed -i '' "s/simple/$(scutil --get LocalHostName)/" flake.nix
   ```

## Installation

### First-Time Setup

1. Make sure the `nixpkgs.hostPlatform` in `flake.nix` matches your system:
   - `aarch64-darwin` for Apple Silicon (M1/M2/M3)
   - `x86_64-darwin` for Intel Macs

2. Update the configuration name in `flake.nix` to match your hostname if desired:
   ```bash
   scutil --get LocalHostName
   ```

3. Update user information in `flake.nix` and `home-manager.nix` to match your setup.

4. Apply the configuration:
   ```bash
   sudo darwin-rebuild switch --flake ~/.config/nix#MacBook-Pro
   ```

   Replace `MacBook-Pro` with the configuration name in your `flake.nix` if different.

## Usage

### Applying Configuration Changes

After modifying any `.nix` files, apply changes with:

```bash
# Full command
sudo darwin-rebuild switch --flake ~/.config/nix

# Or use the shell alias (available after first install)
switch
```

### Updating Dependencies

Update flake inputs (nixpkgs, nix-darwin, home-manager):

```bash
cd ~/.config/nix
nix flake update
sudo darwin-rebuild switch --flake .
```

### Adding Packages

- **GUI Applications**: Add to `homebrew.casks` in `flake.nix`
- **CLI Tools**: Add to `home.packages` in `home-manager.nix`
- **System Packages**: Add to `environment.systemPackages` in `flake.nix`

### Searching for Packages

```bash
nix-env -qaP | grep <package-name>
```

## Useful Commands

```bash
# Apply configuration
switch

# Build without applying
darwin-rebuild build --flake ~/.config/nix

# View changelog
darwin-rebuild changelog

# Get help
darwin-help
```

## Uninstalling

To completely uninstall nix-darwin:

```bash
sudo nix run nix-darwin#darwin-uninstaller
```

## Resources

- [nix-darwin Repository](https://github.com/nix-darwin/nix-darwin)
- [Determinate Systems Nix Installer](https://github.com/DeterminateSystems/nix-installer)
- [home-manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Package Search](https://search.nixos.org/packages)
- [Homebrew Cask Search](https://formulae.brew.sh/cask/)

### Further reading

- [Package management on macOS with nix-darwin](https://davi.sh/blog/2024/01/nix-darwin/)
- [Managing dotfiles on macOS with Nix](https://davi.sh/blog/2024/02/nix-home-manager/)
- [Setting up a development environment with Nix and Home Manager](https://www.rousette.org.uk/archives/setting-up-a-development-environment-with-nix-and-home-manager/)
- [How I use Nix on macOS](https://blog.6nok.org/how-i-use-nix-on-macos/)
- [mitchellh nix config on github](https://github.com/mitchellh/nixos-config/tree/main)
- [Nixing Homebrew: Streamlining package management on your machine](https://dev.to/synecdokey/nix-on-macos-2oj3)
- [Managing dotfiles with nix](https://seroperson.me/2024/01/16/managing-dotfiles-with-nix/)
- [Home manager dotfiles management](https://gvolpe.com/blog/home-manager-dotfiles-management/)

### Other

- [devenv](https://devenv.sh/scripts/#using-your-favourite-language)

