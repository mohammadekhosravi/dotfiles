#
# ~/.zsh_profile
#

[[ -f ~/.zshrc ]] && . ~/.zshrc
[[ $(fgconsole 2>/dev/null) == 1 ]] && exec startx -- vt1

# Created by `pipx` on 2026-01-31 07:01:06
export PATH="$PATH:/home/mamad/.local/bin"
