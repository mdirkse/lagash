set tty (tty)

if [ "$tty" = "/dev/tty1" ]
  exec sway
end
