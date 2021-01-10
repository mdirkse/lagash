include stdlib

# Declare global vars
$bootstrap = lookup('bootstrap')
$user = lookup('user')
$workstation = lookup('workstation')

# And 2 convenience variables cause they're used a lot
$userhome = "/home/${user[username]}"
$username = $user[username]

# Set some defaults
Exec { path => [ '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/' ] }
File {
  backup => false,
  group => $username,
  owner => $username,
}
Package { provider => portage }
Service { provider => systemd }



stage { ['bootstrap', 'finishingtouch']: }
Stage['bootstrap'] -> Stage['main'] -> Stage['finishingtouch']

class { 'bootstrap':
  fs_root => '',
  stage   => bootstrap,
}

class { 'base': } -> class { 'edifice': }
