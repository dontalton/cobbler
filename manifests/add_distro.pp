# Define: cobbler::add_distro
define cobbler::add_distro ($arch,$isolink) {
  include cobbler
  $distro = $title
  $server_ip = $cobbler::server_ip
  $diskpart = $cobbler::params::diskpart

  if $::osfamily == 'RedHat' {
    $kernel = "${cobbler::distro_path}/${distro}/images/pxeboot/vmlinuz"
    $initrd = "${cobbler::distro_path}/${distro}/images/pxeboot/initrd.img"
  } elsif $::osfamily == 'Debian' {
    $kernel = "${cobbler::distro_path}/${distro}/linux"
    $initrd = "${cobbler::distro_path}/${distro}/initrd.gz"
  } else {
    fail ('Unrecognized OS')
  }

  cobblerdistro { $distro :
    ensure  => present,
    arch    => $arch,
    isolink => $isolink,
    destdir => $cobbler::distro_path,
    kernel  => $kernel,
    initrd  => $initrd,
    require => [ Service[$cobbler::service_name], Service[$cobbler::apache_service], File['/etc/cobbler/preseed/cisco-preseed'] ],
  }
  $defaultrootpw = $cobbler::defaultrootpw
  file { "${cobbler::distro_path}/kickstarts/cisco.ks":
    ensure  => present,
    content => template('cobbler/cisco.ks.erb'),
    require => File["${cobbler::distro_path}/kickstarts"],
  }
}
