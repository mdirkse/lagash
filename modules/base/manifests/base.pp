class base::base {

  # Base packages, scripts and services #############################
  package { ['app-arch/unzip',
            'app-arch/zip',
            'dev-vcs/git',
            'net-misc/ntp',
            'sys-apps/usbutils',
            'sys-fs/dosfstools',
            'sys-libs/zlib',
            'sys-power/powertop',
            'sys-process/cronie']:
    ensure  => 'installed',
  }

  # Practically disable swap ########################################
  file { '/etc/sysctl.d/99-sysctl-swappiness.conf':
    ensure  => 'present',
    owner   => '0',
    group   => '0',
    mode    => '0644',
    content => 'vm.swappiness=1',
  }

  # Make sure the time is correct ###################################
  cron { 'keep-time':
    command => '/usr/sbin/ntpdate 0.nl.pool.ntp.org 1.nl.pool.ntp.org',
    user    => 'root',
    minute  => 0,
    require => [Package['net-misc/ntp'],Package['sys-process/cronie']],
  }

  # Set sudoers
  file { '/etc/sudoers':
    ensure  => 'present',
    owner   => '0',
    group   => '0',
    mode    => '0440',
    content => template('base/sudoers.erb'),
  }

  # Configure sysctl.conf
  file { '/etc/sysctl.conf':
    ensure => present,
    owner  => 0,
    group  => 0,
    mode   => '0644',
    source => 'puppet:///modules/base/sysctl.conf',
  }

  exec { 'sysctl -p':
    subscribe   => File['/etc/sysctl.conf'],
    refreshonly => true
  }

  # Facter config
  file { ['/etc/puppetlabs/', '/etc/puppetlabs/facter']:
    ensure => 'directory',
    owner  => 0,
    group  => 0,
    mode   => '0755',
  }

  file { '/etc/puppetlabs/facter/facter.conf':
    ensure => 'directory',
    owner  => 0,
    group  => 0,
    mode   => '0644',
    source => 'puppet:///modules/base/facter.conf'
  }

  # Kernel build script
  $parallel_jobs = $::bootstrap[jobs][make]
  file { '/usr/src/linux/build-and-install-kernel.sh':
    ensure  => present,
    content => template('base/build-install-kernel.sh.erb'),
    owner   => 0,
    group   => 0,
    mode    => '0755',
  }
}
