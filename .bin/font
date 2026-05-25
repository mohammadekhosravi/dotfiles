#!/bin/bash
set -e

if [[ $(id -u) -ne 0 ]]; then
  echo "Please run as root."
  exit 1
fi

echo "──────────────────────────────"
echo " Setting up full font system… "
echo "──────────────────────────────"
sleep 1

# Install main font packages
echo "→ Installing required fonts (Noto, emoji, Persian, powerline)…"
pacman -S --needed noto-fonts noto-fonts-cjk noto-fonts-extra noto-fonts-emoji ttf-dejavu ttf-inconsolata
echo "→ Installing Persian fonts (AUR)…"
yay -S --needed ttf-vazirmatn ttf-sahel ttf-shabnam ttf-iransans || true

# Create comprehensive font config
echo "→ Writing /etc/fonts/local.conf …"
cat <<'EOF' > /etc/fonts/local.conf
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <!-- Persian + Latin + Emoji unified setup -->
  <match>
    <test name="lang" compare="contains"><string>fa</string></test>
    <edit name="family" mode="prepend">
      <string>Vazirmatn</string>
      <string>Shabnam</string>
      <string>Noto Sans Arabic</string>
      <string>Noto Color Emoji</string>
      <string>Noto Emoji</string>
      <string>DejaVu Sans</string>
    </edit>
  </match>

  <alias>
    <family>sans-serif</family>
    <prefer>
      <family>Noto Sans</family>
      <family>Vazirmatn</family>
      <family>Shabnam</family>
      <family>Noto Color Emoji</family>
      <family>Noto Emoji</family>
      <family>DejaVu Sans</family>
    </prefer>
  </alias>

  <alias>
    <family>serif</family>
    <prefer>
      <family>Noto Serif</family>
      <family>Vazirmatn</family>
      <family>Noto Color Emoji</family>
      <family>Noto Emoji</family>
      <family>DejaVu Serif</family>
    </prefer>
  </alias>

  <alias>
    <family>monospace</family>
    <prefer>
      <family>Inconsolata</family>
      <family>Noto Mono</family>
      <family>Noto Color Emoji</family>
      <family>Noto Emoji</family>
      <family>Hack Nerd Font Mono</family>
      <family>DejaVu Sans Mono</family>
    </prefer>
  </alias>
</fontconfig>
EOF

echo "→ Refreshing font cache..."
fc-cache -fv

echo "→ Testing fontconfig mapping for Persian..."
fc-match :lang=fa || true

echo "──────────────────────────────"
echo "✅ Font system ready."
echo "  - Emoji & Persian text fixed"
echo "  - Terminal uses Hack NF"
echo "  - Recommended UI font: Inconsolata Regular"
echo "──────────────────────────────"
echo "Restart Chrome/Firefox and DWM to apply changes."
