class edifice {
  class { 'edifice::dev': }
  class { 'edifice::docker': }
  class { 'edifice::gui': }
  class { 'edifice::sway': }

  # Install the extra packages
  package { $::workstation['extra-packages'] : ensure => installed }
}
