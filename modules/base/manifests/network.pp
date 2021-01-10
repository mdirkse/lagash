class base::network {
  package { ['net-analyzer/netcat',
            'net-analyzer/nmap',
            'net-analyzer/traceroute',
            'net-dns/bind-tools',
            'net-misc/curl',
            'net-misc/networkmanager',
            'net-misc/wget',
            'net-wireless/blueman',
            'net-wireless/bluez']:
    ensure  => 'installed',
  }


  service { 'bluetooth':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => Package['net-wireless/bluez']
  }

  service { 'NetworkManager':
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => Package['net-misc/networkmanager']
  }
}
