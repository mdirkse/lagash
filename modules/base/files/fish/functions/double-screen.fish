function double-screen
  sudo rmmod i2c_hid
  sudo modprobe i2c_hid
  xrandr --output DP-1 --mode 2560x1440 --rotate normal --pos 0x0 --output eDP-1 --mode 1920x1080 --rotate normal --pos 2560x0
  xrandr --output eDP-1 --brightness "1"
end
