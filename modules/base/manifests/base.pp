class base::base {
  $user     = lookup('user')

  user { $::username:
    ensure  => 'present',
    shell   => "/usr/bin/${user['shell']}",
    require => Package[$user['shell']],
  }

  # Directory structure #############################################
  file { ["${userhome}/bin",
          "${userhome}/Apps",
          "${userhome}/Desktop",
          "${userhome}/Documents",
          "${userhome}/Music",
          "${userhome}/Pictures",
          "${userhome}/Scripts",
          "${userhome}/Scripts/utils",
          "${userhome}/Source"]:
    ensure => 'directory',
    owner  => $username,
    group  => $username,
  }

  # Cull screenshots
  tidy { 'screenshot nuke':
    path    => "${userhome}/Pictures",
    recurse => 1,
    age     => '1d',
    matches => 'Screenshot*'
  }

  # Base packages, scripts and services #############################
  package {
    ['blueman',
    'fish',
    'fonts-powerline',
    'git',
    'lsof',
    'nano',
    'ntpdate',
    'pv',
    'rfkill',
    'unzip']:
    ensure  => 'installed',
    require => Exec['update_apt_sources']
  }

  # seperate this one from the rest because we need it to install the repo keys
  package { 'gnupg': ensure  => 'installed' }

  service { ['puppet']:
    ensure    => 'stopped',
    enable    => false,
    hasstatus => true,
  }

  file { "${userhome}/.config":
    ensure => 'directory',
    owner  => $username,
    group  => $username,
    mode   => '0755',
  }

  # Command line environment ########################################
  file { "${userhome}/.config/fish":
    ensure  => 'directory',
    owner   => $username,
    group   => $username,
    mode    => '0700',
    recurse => true,
    source  => 'puppet:///modules/data/fish',
  }

  file { "${userhome}/.config/fish/completions":
    ensure => 'directory',
    owner  => $username,
    group  => $username,
    mode   => '0700',
  }

  vcsrepo { "${userhome}/Apps/oh-my-fish":
    ensure   => present,
    provider => git,
    source   => 'https://github.com/oh-my-fish/oh-my-fish',
    user     => $username,
    require  => File["${userhome}/Apps"],
    notify   => Exec['install-omf'],
  }

  exec { 'install-omf':
    command     => "${userhome}/Apps/oh-my-fish/bin/install --offline --noninteractive",
    refreshonly => true,
    require     => Package['fish'],
  }

  exec { 'install-bobthefish':
    command     => '/usr/bin/fish -c "omf install bobthefish"',
    refreshonly => true,
    subscribe   => Exec['install-omf'],
  }

  # Repos ###########################################################
  lookup('repos').each |$repo| {
    exec { "import_${repo['name']}_key":
      command => "wget -q \"${repo['key']}\" -O- | apt-key add -",
      unless  => "test -f /etc/apt/sources.list.d/${repo['name']}.list",
      require => Package[gnupg],
    }
    file { "/etc/apt/sources.list.d/${repo['name']}.list" :
      ensure  => 'present',
      owner   => '0',
      group   => '0',
      mode    => '0664',
      content => $repo['repo'],
      notify  => Exec['update_apt_sources'],
      require => Exec["import_${repo['name']}_key"]
    }
  }

  exec { 'update_apt_sources' :
    command     => 'apt-get update',
    refreshonly => true
  }

  # Disable kernel modules ###############################################
  $disabled_modules = ['pcspkr']

  $disabled_modules.each |$module| {
    file { "/etc/modprobe.d/blacklist-${module}.conf":
      ensure  => 'present',
      owner   => '0',
      group   => '0',
      mode    => '0644',
      content => "blacklist ${module}\n",
    }
  }

  # Practically disable swap ########################################
  file { '/etc/sysctl.d/99-sysctl-swappiness.conf':
    ensure  => 'present',
    owner   => '0',
    group   => '0',
    mode    => '0644',
    content => 'vm.swappiness=1',
  }

  # Install all the scripts #########################################
  $scripts = lookup('scripts')
  if $scripts != undef {
    $scripts.each |$script| {
      base::extrafile { "${userhome}/bin/${script}":
        type => 'file',
        src  => 'scripts',
        mode => '0750',
      }
    }
  }

  # Set display brightness when switching from battery to ac and vice versa
  $spdb = "${userhome}/bin/set-power-display-brightness.sh"
  file { $spdb:
    ensure => 'present',
    owner  => $username,
    group  => $username,
    mode   => '0750',
    source => 'puppet:///modules/base/set-power-display-brightness.sh',
  }

  file { '/etc/udev/rules.d/99-power-display-brightness.rules':
    ensure  => 'present',
    owner   => '0',
    group   => '0',
    mode    => '0644',
    content => "SUBSYSTEM==\"power_supply\", ENV{POWER_SUPPLY_ONLINE}==\"[01]\", RUN+=\"${spdb}\"\n",
    require => File[$spdb],
  }

  # Make sure the time is correct ###################################
  cron { 'keep-time':
    command => '/usr/sbin/ntpdate 0.nl.pool.ntp.org 1.nl.pool.ntp.org',
    user    => 'root',
    minute  => 0,
    require => Package['ntpdate'],
  }

  # Git ########################################
  file { "${userhome}/.gitconfig":
    ensure  => 'present',
    owner   => $username,
    group   => $username,
    mode    => '0664',
    content => template('base/gitconfig.erb'),
  }
}
