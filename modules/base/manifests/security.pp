class base::security {
  # SSH #############################################################
  file { '/etc/sudoers':
    ensure  => 'present',
    owner   => '0',
    group   => '0',
    mode    => '0440',
    content => template('base/sudoers.erb'),
  }

  file { "${userhome}/.ssh":
    ensure  => 'directory',
    owner   => $username,
    group   => $username,
    mode    => '0600',
    source  => 'puppet:///modules/data/keys',
    ignore  => '.gitignore',
    purge   => true,
    recurse => true,
  }

  file { "${userhome}/.ssh/config":
    ensure => 'present',
    owner  => $username,
    group  => $username,
    mode   => '0664',
    source => 'puppet:///modules/data/ssh_config',
  }

  # Gotta list this to make sure it doesn't get deleted as we set the "recurse" option on the directory
  file { "${userhome}/.ssh/known_hosts":
    ensure  => 'file',
    owner   => $username,
    group   => $username,
    mode    => '0600',
    content => '',
    replace => false,
  }
}
