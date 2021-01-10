define edifice::tool ($app, $appsdir, $repo_subdir='repo') {
  $toolsrepo = "${appsdir}/${repo_subdir}"

  # First, make sure the repo subdir exists
  ensure_resource('file', $toolsrepo,
    { 'ensure' => 'directory',
      'owner'  => $::username,
      'group'  => $::username,
      'mode'   => '0644'
    }
  )

  $archdest  = "${toolsrepo}/${app['name']}-${app['version']}"
  $apparch   = regsubst($app['archive'], 'VERSION', $app['version'], 'G')
  $appdir    = regsubst($app['dir'], 'VERSION', $app['version'], 'G')
  $appdest   = "${appsdir}/${appdir}"
  $archcom   =  $app['archive'] ? {
    /\.tar\.bz2$/ => 'tar xfj ',
    /\.tar\.gz$/  => 'tar xfz ',
    /\.tgz$/      => 'tar xfz ',
    default       => 'unzip -qq'
  }

  exec { "download-${app['name']}":
    command => "wget -q -O ${archdest} ${apparch}",
    creates => $archdest,
    user    => $::username,
    group   => $::username,
    require => File[$toolsrepo],
  }

  exec { "extract-${app['name']}":
    command => "${archcom} ${archdest}",
    cwd     => "${::userhome}/Apps/",
    user    => $::username,
    group   => $::username,
    creates => $appdest,
    require => Exec["download-${app['name']}"],
  }

  $app['executables'].each |$exec| {
    $symlink = regsubst($exec, '^.+\/(.+)$', '\1')
    file { "${::userhome}/bin/${symlink}":
      ensure  => 'link',
      owner   => $::username,
      group   => $::username,
      target  => "${appdest}${exec}",
      require => Exec["extract-${app['name']}"]
    }
  }

  if has_key($app, 'extrafiles') {
    $app['extrafiles'].each |$file| {
      # If the file is prepended with tilde, replace it with $userhome
      $dest = $file['dest'] ? {
        /^~/    => regsubst($file['dest'], '^~', $::userhome),
        default => $file['dest']
      }

      base::extrafile { $dest:
        type => $file['type'],
        src  => "development/${app['name']}",
        mode => $file['mode']
      }
    }
  }
}
