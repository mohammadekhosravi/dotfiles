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

7. xbindkeys

   ```sh
   sudo pacman -S xbindkeys
   ```
   for keyboard layout switch

8. xkb-switch

   ```sh
   sudo yay -S xkb-switch
   ```

   for keyboard layout switch. all other pieces are all ready set up.
   you need to use `setxkbmap -layout us,ir` then, `setxkbmap` and config `Alt+n` to do `xkb-switch -n` in the `~/.xbindkeysrc`

9. feh
   ```sh
   sudo pacman -S feh
   feh --bg-fill /path/to/wallpaper.jpg
   ```

   for setting wallpaper

10. Xorg session

    ```sh
    sudo pacman -S xorg-xinit xorg-xrandr
    ```

    the session is started with `startx` from `.zprofile`.

11. dwm and dwmblocks

    compiled from source, they are the window manager and the status bar.
    `dwmblocks` reads the `sb-*` scripts from `~/.bin`.

12. picom

    ```sh
    sudo pacman -S picom
    ```

    compositor for transparency and vsync (config: `~/.config/picom.conf`)

13. blueman

    ```sh
    sudo pacman -S blueman
    ```

    bluez applet started from `.xinitrc`

14. gnome-keyring

    ```sh
    sudo pacman -S gnome-keyring
    ```

    keyring daemon started from `.xinitrc`

15. dmenu

    ```sh
    sudo pacman -S dmenu
    ```

    used by `~/.bin/dmenu-smb` to mount SMB shares

16. smbclient

    ```sh
    sudo pacman -S samba
    ```

    used by `~/.bin/dmenu-smb`

17. pactl (PulseAudio control)

    ```sh
    sudo pacman -S pipewire-pulse
    ```

    used by `~/.bin/sb-vol` and `~/.bin/create-android-sync` (null sink "AndroidOnly")

18. Neovim

    ```sh
    ~/.bin/nvim-bootstrap
    ```

    installs Neovim with all LSP/tooling dependencies (nvm, node, npm packages, etc.)

## Scripts (`~/.bin`)

| script             | purpose                                                  |
| ------------------ | -------------------------------------------------------- |
| `nvim-bootstrap`   | one-shot Neovim + toolchain setup                        |
| `dmenu-smb`        | mount/unmount Windows SMB shares (`-u` for unmount)      |
| `monitorResolution`| applies the 2560x1440@119.90 modeline on startup         |
| `create-android-sync` | virtual audio sink for AudioRelay                     |
| `autocaffeine`     | disables screensaver while vlc/mpv is playing            |
| `font`             | installs Persian/emoji fonts and writes fontconfig rules |
| `mount`            | mounts VMware shared folders                             |
| `sb-clock`         | dwmblocks: clock                                        |
| `sb-internet`      | dwmblocks: wifi ssid (click for nmtui)                   |
| `sb-vol`           | dwmblocks: volume (click/scroll to control)              |

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
chsh -s /usr/bin/zsh
```

then log out and back in (or `startx` from a tty) to bring up the X session.