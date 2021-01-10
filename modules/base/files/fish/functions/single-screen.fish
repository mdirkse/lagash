function single-screen
  sudo rmmod i2c_hid
  sudo modprobe i2c_hid
  xrandr --output eDP-1 --brightness "0.5"
end
