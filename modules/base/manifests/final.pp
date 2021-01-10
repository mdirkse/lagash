class base::final {
  # Do a reload of systemd if anything needs it
  exec { 'systemd-reload':
    command     => 'systemctl daemon-reload',
    refreshonly => true,
  }
}
