class edifice::docker {
  package { 'app-emulation/docker': ensure => 'installed' }

  file { '/etc/docker/daemon.json':
    ensure  => 'present',
    owner   => '0',
    group   => '0',
    mode    => '0644',
    source  => 'puppet:///modules/edifice/docker-daemon.json',
    require => Service['docker'],
    notify  => Exec['systemd-reload'],
  }

  service { 'docker':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => Package['app-emulation/docker'],
  }

  # Make sure the user is in the docker group otherwise they can't issue docker commands
  exec { "usermod -aG docker ${::username}":
    unless  => "groups ${::username} | grep docker",
    require => [User[$::username], Package['app-emulation/docker']],
  }
}
