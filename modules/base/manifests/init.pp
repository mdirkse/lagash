class base() {
  class { 'base::base':} -> class { ['base::network', 'base::rust', 'base::shell', 'base::user']:}
  class { 'base::final': stage => 'finishingtouch' }
}
