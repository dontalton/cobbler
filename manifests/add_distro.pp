# Define: cobbler::add_distro
define cobbler::add_distro ($arch,$isolink, $distro_os) {
  include cobbler
  $distro = $title
  $server_ip = $cobbler::server_ip

  if $distro_os == 'rhel' {
    $kernel = "${cobbler::distro_path}/${distro}/images/pxeboot/vmlinuz"
    $initrd = "${cobbler::distro_path}/${distro}/images/pxeboot/initrd.img"
  } elsif $distro_os == 'debian' {
    $kernel = "${cobbler::distro_path}/${distro}/linux"
    $initrd = "${cobbler::distro_path}/${distro}/initrd.gz"
  }

  cobblerdistro { $distro :
    ensure  => present,
    arch    => $arch,
    isolink => $isolink,
    destdir => $cobbler::distro_path,
    kernel  => $kernel,
    initrd  => $initrd,
    require => [ Service[$cobbler::service_name], Service[$cobbler::apache_service] ],
  }
  $defaultrootpw = $cobbler::defaultrootpw
  file { "${cobbler::distro_path}/kickstarts/${distro}.ks":
    ensure  => present,
    content => template("cobbler/${distro}.ks.erb"),
    require => File["${cobbler::distro_path}/kickstarts"],
  }
}
