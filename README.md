# Personal development machine setup
I manage my personal development machine using [Puppet](https://puppet.com/) and like to automate as many parts of the setup as I can. The setup of the machine itself is defined in `workstation.pp` and applied using `run_puppet.sh`. 

## Characteristics
**OS:** [Gentoo](https://www.gentoo.org/)  
**FS:** [ZFS](https://zfsonlinux.org/)  
**GUI:** [Wayland](https://wayland.freedesktop.org/)  
**Window Manager:** [Sway](https://swaywm.org/)

## Bootstrapping
I also use Puppet to bootstrap the machine and automate as much of the Gentoo installation as possible. The bootstrap configuration is defined in `bootstrap/bootstrap.pp`.

The bootstrap config is applied by booting the machine using an Ubuntu live USB stick, installing git, cloning this repository and running `bootstrap/bootstrap.sh`.

The bootstrap configuration is mostly copied from https://wiki.gentoo.org/wiki/User:Bugalo/Dell_XPS_15_7590 and https://wiki.gentoo.org/wiki/User:Fearedbliss/Installing_Gentoo_Linux_On_ZFS.