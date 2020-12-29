class bootstrap (String $fs_root) {
  mount { "${fs_root}/boot/efi":
    ensure  => 'mounted',
    device  => "${::bootstrap[disk]}p1",
    fstype  => 'vfat',
    require => File["${fs_root}/boot/efi"],
  }

  file { ["${fs_root}/boot/efi",
          "${fs_root}/boot/grub",
          "${fs_root}/etc/portage/repos.conf",
          "${fs_root}/etc/portage/savedconfig/sys-kernel"]:
    ensure => directory,
    owner  => 0,
    group  => 0,
  }

  $emerge_jobs = $::bootstrap[jobs][emerge]
  $make_jobs = $::bootstrap[jobs][make]

  $bpool = $::bootstrap[zpool][boot][name]
  $rpool = $::bootstrap[zpool][root][name]
  $zfs_ds_os = "${rpool}/${::bootstrap[zpool][root][ds][os]}"
  $zfs_ds_home = "${rpool}/${::bootstrap[zpool][root][ds][home]}"

  $files = [
    {
      location => '/boot/kitten.jpg',
      content => file('bootstrap/kitten.jpg')
    },
    {
      location => '/etc/conf.d/hostname',
      content => "hostname=\"${::bootstrap[hostname]}\""
    },
    {
      location => '/etc/default/grub',
      content => template('bootstrap/grub.conf.erb')
    },
    {
      location => '/etc/hostname',
      content => $::bootstrap[hostname]
    },
    {
      location => '/etc/locale.gen',
      content => file('bootstrap/locale.gen')
    },
    {
      location => '/etc/portage/make.conf',
      content => template('bootstrap/portage/make.conf'),
    },
    {
      location => '/etc/portage/package.accept_keywords',
      content => file('bootstrap/portage/package.accept_keywords'),
    },
    {
      location => '/etc/portage/package.use',
      content => file('bootstrap/portage/package.use'),
    },
    {
      location => '/etc/portage/repos.conf/gentoo.conf',
      content => file('bootstrap/portage/gentoo.conf')
    },
    {
      location => '/etc/portage/savedconfig/sys-kernel/linux-firmware-20201218',
      content => file('bootstrap/linux-firmware-20201218')
    },
    {
      location => '/etc/systemd/system/zfs-import-bpool.service',
      content => template('bootstrap/systemd/zfs-import-bpool.service.erb')
    },
    {
      location => '/etc/systemd/system/zfs-import-home.service',
      content => template('bootstrap/systemd/zfs-import-home.service.erb')
    },
    {
      location => '/etc/timezone',
      content => 'Europe/Amsterdam'
    },
    {
      location => '/tmp/kernel.config',
      content => file('bootstrap/kernel.config')
    }
  ]

  $files.each | $f | {
    file { "${fs_root}${f[location]}":
      ensure  => file,
      owner   => 0,
      group   => 0,
      mode    => '0644',
      force   => true,
      content => $f[content],
    }
  }
}
