#!/bin/sh

xrandr --newmode "2560x1440_120.00"  661.25  2560 2784 3064 3568  1440 1443 1448 1545 -hsync +vsync &
sleep 0.1
xrandr --addmode Virtual1 2560x1440_120.00 &
sleep 0.1
xrandr --output Virtual1 --mode 2560x1440_120.00
