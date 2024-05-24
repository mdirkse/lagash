function fix-bluetooth
  sudo rmmod btusb
  sudo rmmod btintel
  sleep 2
  sudo modprobe btintel
  sudo modprobe btusb
end
