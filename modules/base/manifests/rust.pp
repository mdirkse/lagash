class base::rust {
  # Make sure clang stuff is installed for bindgen and we use the fast linker
  package { ['dev-lang/rust-bin',
            'sys-devel/clang',
            'sys-devel/lld',
            'sys-devel/llvm']:
    ensure => installed,
  }

  file { "${::userhome}/.cargo":
    ensure => 'directory',
    mode   => '0644'
  }

  file { 'cargo-conf':
    ensure  => 'present',
    path    => "${::userhome}/.cargo/config",
    mode    => '0644',
    content => template('base/cargo.config.erb')
  }

  # Install the cargo packages
  $cargoapps = $::workstation[cargo][apps]
  $cargoapps_installed = cargo_apps($::username, $::userhome)

  $cargoapps.each | String $app | {
    if ! ($app in $cargoapps_installed) {
      exec { "cargo install ${app}":
        user    => $::username,
        path    => ['/usr/bin'],
        require => [Package['dev-lang/rust-bin'],File['cargo-conf']]
      }
    }
  }
}
