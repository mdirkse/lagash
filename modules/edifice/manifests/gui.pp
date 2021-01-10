class edifice::gui {
  package { [ 'gnome-extra/nm-applet',
              'gui-apps/mako',
              'gui-apps/waybar',
              'media-gfx/imagemagick',
              'media-libs/glu',
              'x11-misc/pcmanfm',
              'x11-terms/kitty',
              'www-client/google-chrome']:
    ensure => installed
  }

  # Kitty ###########################################################
  file { "${::userhome}/.config/kitty":
    ensure => 'directory',
    mode   => '0755',
  }

  file { "${::userhome}/.config/kitty/kitty.conf":
    ensure => present,
    mode   => '0644',
    source => 'puppet:///modules/edifice/kitty_config',
  }

  file { "${::userhome}/.config/fish/conf.d/kitty.fish":
    ensure  => present,
    mode    => '0700',
    content => 'set -x KITTY_ENABLE_WAYLAND 1',
  }

  # Waybar ##########################################################
  $waybar_confd = "${::userhome}/.config/waybar"
  file { $waybar_confd:
    ensure => 'directory',
    mode   => '0755',
  }

  file { "${waybar_confd}/config":
    ensure => present,
    mode   => '0644',
    source => 'puppet:///modules/edifice/waybar/config',
  }

  file { "${waybar_confd}/style.css":
    ensure => present,
    mode   => '0644',
    source => 'puppet:///modules/edifice/waybar/style.css',
  }

  # Mako ############################################################
  $mako_confd = "${::userhome}/.config/mako"
  file { $mako_confd:
    ensure => 'directory',
    mode   => '0755',
  }

  file { "${mako_confd}/config":
    ensure => present,
    mode   => '0644',
    source => 'puppet:///modules/edifice/mako_config',
  }

  # Fonts ###########################################################
  $fonts_home  = "${::userhome}/.fonts"

  file { $fonts_home:
      ensure => directory,
      mode   => '0775',
  }

  archive { '/tmp/fonts.zip':
    ensure       => present,
    creates      => "${fonts_home}/fonts-master",
    cleanup      => true,
    extract      => true,
    extract_path => $fonts_home,
    require      => File[$fonts_home],
    source       => $::workstation[fonts],
  }

  # Other ###########################################################
  # Make IDEA and such work under Wayland
  file { "${::userhome}/.config/fish/conf.d/java_wayland.fish":
    ensure  => present,
    mode    => '0700',
    content => 'set -x _JAVA_AWT_WM_NONREPARENTING 1',
  }
}
