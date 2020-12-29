#!/bin/bash
BRIGHTNESS=$([ "${POWER_SUPPLY_ONLINE}" = "1" ] && echo "120000" || echo "36000")
sudo su -c "echo ${BRIGHTNESS} > /sys/class/backlight/intel_backlight/brightness"
