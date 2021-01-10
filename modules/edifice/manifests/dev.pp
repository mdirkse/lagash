class edifice::dev {
  package { ['app-emulation/virtualbox',
            'app-emulation/virtualbox-extpack-oracle',
            'app-misc/jq',
            'dev-java/openjdk-bin',
            'dev-util/shellcheck-bin',
            'sys-devel/gdb']:
    ensure => installed
  }

  # Make sure the user can use virtualbox
  exec { "usermod -aG vboxusers ${::username}":
    unless  => "groups ${::username} | grep vboxusers",
    require => [User[$::username], Package['app-emulation/virtualbox']],
  }

  # Install the custom apps
  $dev_apps = $::workstation[dev-apps]
  $dev_apps.each |$app| {
    edifice::tool { $app[1]['name']:
      app     => $app[1],
      appsdir => "${::userhome}/Apps",
    }
  }

  file { "${::userhome}/.config/fish/conf.d/dev-env-vars.fish":
    ensure  => 'present',
    mode    => '0700',
    content => template('edifice/dev-env-vars.fish.erb')
  }

  # Setup sublime and vscode prefs
  $prefs_dirs = ["${::userhome}/.config/Code",
                  "${::userhome}/.config/Code/User"]

  file { $prefs_dirs:
    ensure => 'directory',
    mode   => '0700',
  }

  file { 'vscode-keymap':
    ensure => 'present',
    path   => "${::userhome}/.config/Code/User/keybindings.json",
    mode   => '0644',
    source => 'puppet:///modules/edifice/vscode/keybindings.json'
  }

  file { 'vscode-settings':
    ensure => 'present',
    path   => "${::userhome}/.config/Code/User/settings.json",
    mode   => '0644',
    source => 'puppet:///modules/edifice/vscode/settings.json'
  }

  # Setup kubectl helper commands + fish autocomplete
  $kubectx_home = "${::userhome}/Apps/kubectx"
  vcsrepo { $kubectx_home:
    ensure   => present,
    provider => git,
    source   => 'https://github.com/ahmetb/kubectx.git',
    user     => $::username,
    require  => File["${::userhome}/Apps"],
  }

  file { "${::userhome}/bin/kctx":
    ensure  => 'link',
    target  => "${kubectx_home}/kubectx",
    require => Vcsrepo[$kubectx_home],
  }

  file { "${::userhome}/bin/kns":
    ensure  => 'link',
    target  => "${kubectx_home}/kubens",
    require => Vcsrepo[$kubectx_home],
  }

  file { "${::userhome}/.config/fish/completions/kubectx.fish":
    ensure => 'link',
    target => "${kubectx_home}/completion/kubectx.fish",
  }

  file { "${::userhome}/.config/fish/completions/kubens.fish":
    ensure => 'link',
    target => "${kubectx_home}/completion/kubens.fish",
  }

  # Gradle config
  file { "${::userhome}/.gradle": ensure  => directory }

  file { "${::userhome}/.gradle/gradle.properties":
    ensure => present,
    mode   => '0644',
    source => 'puppet:///modules/edifice/gradle.properties'
  }
}
