class base::user {
  $userhome = "/home/${::user[username]}"
  $username = $::user[username]

  user { $username:
    ensure  => 'present',
    groups  => ['input'],
    shell   => "/bin/${::workstation[shell][name]}",
    require => Package[$::workstation[shell][package]],
  }

  # Directory structure #############################################
  file { ["${::userhome}/.config",
          "${::userhome}/bin",
          "${::userhome}/Apps",
          "${::userhome}/Desktop",
          "${::userhome}/Pictures",
          "${::userhome}/Source"]:
    ensure => 'directory',
  }

  # Cull screenshots
  tidy { 'screenshot nuke':
    path    => "${::userhome}/Pictures",
    recurse => 1,
    age     => '1d',
    matches => 'Screenshot*',
  }

  # Remove unwanted Windows VM artifacts
  file { ["${::userhome}/Desktop/System Volume Information",
          "${::userhome}/Desktop/Thumbs.db",
          "${::userhome}/Desktop/Thumbs.db:encryptable"]:
    ensure => absent,
    force  => true,
  }

  # Git ########################################
  file { "${::userhome}/.gitconfig":
    ensure  => 'present',
    mode    => '0664',
    content => template('base/gitconfig.erb'),
  }

  # SSH ########################################
  file { "${::userhome}/.ssh/config":
    ensure => 'present',
    mode   => '0600',
    source => 'puppet:///modules/base/ssh_config',
  }

  # Gotta list this to make sure it doesn't get deleted as we set the "recurse" option on the directory
  file { "${::userhome}/.ssh/known_hosts":
    ensure  => 'file',
    mode    => '0600',
    content => '',
    replace => false,
  }
}
