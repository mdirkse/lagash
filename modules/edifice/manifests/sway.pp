class edifice::sway {
  package { ['gui-apps/grim',
            'gui-apps/slurp',
            'gui-apps/swayidle',
            'gui-apps/swaylock',
            'gui-apps/wl-clipboard',
            'gui-wm/sway']:
    ensure => installed
  }
  file { '/usr/bin/sway':
    ensure  => present,
    owner   => 0,
    group   => 0,
    mode    => '6755',
    require => Package['gui-wm/sway'],
  }

  $swaydir="${::userhome}/.config/sway"
  file { [$swaydir, "${swaydir}/monitors"]:
    ensure => 'directory',
    owner  => $::username,
    group  => $::username,
    mode   => '0644',
  }

  # Variables needed for the config
  $app_pinning = $::workstation[sway][app-pinning]
  $floating = $::workstation[sway][floating]
  $startup = $::workstation[sway][startup]
  $wallpaper = "${::userhome}/${::workstation[sway][wallpaper]}"

  file { "${swaydir}/config":
    ensure  => 'present',
    owner   => $::username,
    group   => $::username,
    content => template('edifice/sway/swayconfig.erb')
  }

  ### Multi-monitor management stuff
  $windowconfigscript='bin/configurewindowing.sh'
  file { 'window-config-script':
    ensure  => 'present',
    path    => "${::userhome}/${windowconfigscript}",
    owner   => $::username,
    group   => $::username,
    mode    => '0755',
    content => template('edifice/configurewindowing.sh.erb'),
  }

#  file { '/etc/udev/rules.d/99-configure-displays.rules':
#    ensure  => 'present',
#    owner   => '0',
#    group   => '0',
#    mode    => '0644',
#    content => template('gui/udev-configure-display.erb'),
#    require => File['window-config-script']
#  }

  # Automatically launch Sway when logging in to tty1
  file { "${::userhome}/.config/fish/conf.d/z-launch-sway.fish":
    ensure => present,
    mode   => '0700',
    source => 'puppet:///modules/edifice/z-launch-sway.fish'
  }
}
