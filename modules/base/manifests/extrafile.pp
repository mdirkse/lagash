# The name must end in the filename of the extra file. This filename must be the same as the name of the source file.
# The name will be used to find the source file.
define base::extrafile ($type, $src, $mode='0640') {
  case $type {
    'directory': {
      file { $name:
        ensure => 'directory',
        owner  => $username,
        group  => $username,
        mode   => $mode,
      }
    }
    default: {
      $filename = reverse(split($name, '/'))[0]
      $content = $type ? {
        'template' => template("data/${src}/${filename}"),
        default    => undef
      }
      $source = $type ? {
        'file'  => "puppet:///modules/data/${src}/${filename}",
        default => undef
      }

      # Rather than adding either content or source, add both, just make sure one of the two is undef
      file { $name:
        ensure  => 'present',
        owner   => $username,
        group   => $username,
        mode    => $mode,
        content => $content,
        source  => $source
      }
    }
  }
}