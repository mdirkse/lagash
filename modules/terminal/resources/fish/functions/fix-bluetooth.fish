function fix-bluetooth
  sudo rmmod btusb
  sudo modprobe btusb
end
