Exec { path => [ '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/' ] }
File { backup => false }

# Make sure all the bootstrapping is done *after* stage3 is extracted
stage { ['bootstrap']: }
Stage['main'] -> Stage['bootstrap']

$bootstrap = lookup('bootstrap')

archive { 'stage3':
  ensure          => present,
  path            => '/tmp/stage3.tar.xz',
  source          => $bootstrap[stage3][url],
  checksum        => $bootstrap[stage3][checksum],
  checksum_type   => 'sha512',
  extract         => true,
  extract_path    => $bootstrap[mount],
  extract_command => 'tar xpf %s --xattrs-include=\'*.*\' --numeric-owner',
  creates         => "${$bootstrap[mount]}/bin",
  cleanup         => true,
}

class { 'bootstrap':
  stage   => bootstrap,
  fs_root => $bootstrap[mount],
}

$files = [
  '/etc/resolv.conf',
  '/etc/zfs/zpool.cache',
  '/etc/hostid'
]

file {"${bootstrap[mount]}/etc/zfs":
  ensure  => directory,
  owner   => 0,
  group   => 0,
  require => Archive['stage3'],
}

$files.each |String $loc| {
  file {"${bootstrap[mount]}${loc}":
    ensure  => present,
    source  => $loc,
    links   => follow,
    require => Archive['stage3'],
  }
}

# Place the chroot bootstrap scripts
$chroot_bootstrap_dir='/tmp/bootstrap'
file {"${bootstrap[mount]}${chroot_bootstrap_dir}":
  ensure  => directory,
  owner   => 0,
  group   => 0,
  purge   => true,
  recurse => true,
  require => Archive['stage3'],
}

$chroot_scripts = [
  'finish-config',
  'install-packages',
  'install-grub',
  'install-kernel',
  'prepare-emerge',
  'upgrade-world-and-use',
]

$chroot_scripts.each |String $s| {
  file {"${bootstrap[mount]}${chroot_bootstrap_dir}/${s}.sh":
    ensure  => present,
    owner   => 0,
    group   => 0,
    mode    => '0755',
    content => file("bootstrap/chroot/${s}.sh"),
    require => Archive['stage3'],
  }
}

# Do the necessary mounts
exec { 'mount --types proc /proc /mnt/gentoo/proc':
  creates => "${$bootstrap[mount]}/proc/cpuinfo",
  require => Archive['stage3'],
}

exec { 'mount sys':
  command => 'mount --rbind /sys /mnt/gentoo/sys',
  creates => "${$bootstrap[mount]}/sys/block",
  require => Archive['stage3'],
}

exec { 'mount --make-rslave /mnt/gentoo/sys':
  refreshonly => true,
  subscribe   => Exec['mount sys']
}

exec { 'mount dev':
  command => 'mount --rbind /dev /mnt/gentoo/dev',
  creates => "${$bootstrap[mount]}/dev/cpu",
  require => Archive['stage3'],
}

exec { 'mount --make-rslave /mnt/gentoo/dev':
  refreshonly => true,
  subscribe   => Exec['mount dev']
}
