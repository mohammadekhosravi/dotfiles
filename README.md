# Dotfiles

This directory contains all of config files for replicating current system, managed by gnu stow.

## Requirements

1. stow

   ```sh
   sudo pacman -S stow
   ```

   above command would install stow. this utility create symbolic link between files that it's manage and home directory.

2. zsh

   ```sh
   sudo pacman -S zsh
   ```

3. konsole

   ```sh
   sudo pacman -S konsole
   ```

   konsole is the only terminal emulator that i found the properly support farsi

4. Hack Nerd Font
   ```sh
   sudo pacman -S ttf-hack-nerd
   ```
5. fzf

   ```sh
   sudo pacman -S fzf
   ```

   for fuzzy finding history via zsh and other stuff

6. zoxide

   ```sh
   sudo pacman -S zoxide
   ```

   for z command

7. xkb-switch

   ```sh
   sudo yay -S xkb-switch
   ```

   for keyboard layout switch. all other pieces are all ready set up.
   you need to use `setxkbmap -layout us,ir` then, `setxkbmap` and config `Alt+n` to do `xkb-switch -n` in the `~/.xbindkeysrc`

## Usage

First, clone this repo.

```sh
git clone git@github.com:mohammadekhosravi/dotfiles.git
cd dotfiles
```

then use stow to create symlinks

```sh
stow .
```

Make zsh primary shell

```sh
chsh $(whoami)
```
