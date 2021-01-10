class base::shell {
  package { [$::workstation[shell][package],
            'app-editors/nano',
            'sys-apps/pv',
            'sys-process/lsof']:
    ensure  => 'installed'
  }

  # Command line environment ########################################
  file { "${::userhome}/.config/fish":
    ensure  => 'directory',
    mode    => '0700',
    recurse => true,
    source  => 'puppet:///modules/base/fish',
  }
  file { "${::userhome}/.config/fish/conf.d":
    ensure => 'directory',
    mode   => '0700',
  }

  file { "${::userhome}/.config/fish/completions":
    ensure => 'directory',
    mode   => '0700',
  }

  # Exec scripts 
  $::workstation[exec-scripts].each | Hash $script | {
    file { "${::userhome}/bin/${script[name]}":
      ensure  => present,
      mode    => '0755',
      content => "#! /bin/bash\nexec ${script[content]}",
    }
  }

#  vcsrepo { "${userhome}/Apps/oh-my-fish":
#    ensure   => present,
#    provider => git,
#    source   => 'https://github.com/oh-my-fish/oh-my-fish',
#    user     => $username,
#    require  => File["${userhome}/Apps"],
#    notify   => Exec['install-omf'],
#  }
#
#  exec { 'install-omf':
#    command     => "${userhome}/Apps/oh-my-fish/bin/install --offline --noninteractive",
#    refreshonly => true,
#    require     => Package['fish'],
#  }
#
#  exec { 'install-bobthefish':
#    command     => '/usr/bin/fish -c "omf install bobthefish"',
#    refreshonly => true,
#    subscribe   => Exec['install-omf'],
#  }
}
