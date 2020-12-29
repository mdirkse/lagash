class base::final {
  $apps     = lookup('apps')

  service { ['avahi-daemon', 'mcollective', 'nfs-server', 'rpcbind', 'systemd-timesyncd']:
    ensure     => 'stopped',
    enable     => false,
    hasstatus  => true,
    hasrestart => true,
  }

  if has_key($apps, 'install') {
    package { $apps['install']:
      ensure => 'installed',
      notify => Exec['autoremove']
    }
  }

  if has_key($apps, 'remove') {
    package { $apps['remove']:
      ensure => 'purged',
      notify => Exec['autoremove']
    }
  }

  exec { 'autoremove':
    command     => 'apt-get autoremove -y',
    refreshonly => true
  }

  # Generic systemd reload should anything need it ##################
  exec { 'systemd-reload':
    command     => 'systemctl daemon-reload',
    refreshonly => true,
  }
}
