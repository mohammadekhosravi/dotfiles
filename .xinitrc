#!/bin/sh

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

# start some nice programs

if [ -d /etc/X11/xinit/xinitrc.d ]; then
    for f in /etc/X11/xinit/xinitrc.d/?*.sh; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

# for vscode login
# see https://unix.stackexchange.com/a/295652/332452
source /etc/X11/xinit/xinitrc.d/50-systemd-user.sh

# see https://wiki.archlinux.org/title/GNOME/Keyring#xinitrc
eval $(/usr/bin/gnome-keyring-daemon --start)
export SSH_AUTH_SOCK

# see https://github.com/NixOS/nixpkgs/issues/14966#issuecomment-520083836
mkdir -p "$HOME"/.local/share/keyrings

monitorResolution &
# make capslock do the esc work too.
sleep .5
setxkbmap -option caps:escape &
setxkbmap -layout us,ir &
xbindkeys &
# compositor(transparency, animation)
sleep .5
picom &
dwmblocks &
# Create a virtual sink named "AndroidOnly" for outputing sound
create-android-sync &
# Bluetooth
blueman-applet &
# Check if play full screen video, then don't turn off screen
# autocaffeine &

# restore background (wait briefly to avoid race condition)
sleep .5
[ -f "$HOME/.fehbg" ] && "$HOME/.fehbg" &

exec dwm
