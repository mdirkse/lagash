class base {
  class { 'base::base': }
  -> class { 'base::security': }

  class { 'base::final': stage => 'finishingtouch' }
}
