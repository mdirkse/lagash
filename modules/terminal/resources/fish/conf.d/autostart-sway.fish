if test -z "$WAYLAND_DISPLAY" -a "$XDG_VTNR" = 1
  exec sway --unsupported-gpu
end
