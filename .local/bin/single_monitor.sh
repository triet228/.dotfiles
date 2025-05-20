#!/bin/bash

# Set only the primary monitor, disable the secondary one
xrandr --output HDMI-1 --primary --mode 1920x1080 --pos 0x0 --rotate normal \
       --output HDMI-1-0 --off

