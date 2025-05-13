if test -z "$WAYLAND_DISPLAY" -a "$XDG_VTNR" = 1

  if systemctl --user -q is-active niri.service;
    echo 'A niri session is already running.'
    exit 1
  end

  # Reset failed state of all user units.
  systemctl --user reset-failed

  # Import the login manager environment.
  systemctl --user import-environment

  # DBus activation environment is independent from systemd. While most of
  # dbus-activated services are already using `SystemdService` directive, some
  # still don't and thus we should set the dbus environment with a separate
  # command.
  if which dbus-update-activation-environment 2>&1 > /dev/null;
      dbus-update-activation-environment --all
  end

  # Start niri and wait for it to terminate.
  systemctl --user --wait start niri.service

  # Force stop of graphical-session.target.
  systemctl --user start --job-mode=replace-irreversibly niri-shutdown.target

  # Unset environment that we've set.
  systemctl --user unset-environment WAYLAND_DISPLAY XDG_SESSION_TYPE XDG_CURRENT_DESKTOP NIRI_SOCKET

end
