#!/bin/sh

sleep 1
OUTPUT=$(xrandr | grep " connected" | awk '{print $1}')
MODE="2560x1440_120.00"

# 2560×1440 at 120 Hz modeline calculated via cvt 2560 1440 120
if ! xrandr | grep -q "$MODE"; then
    xrandr --newmode "$MODE" 1089.00 2560 2760 3040 3520 1440 1443 1448 1500 -hsync +vsync
    xrandr --addmode "$OUTPUT" "$MODE"
fi

xrandr --output "$OUTPUT" --mode "$MODE"
