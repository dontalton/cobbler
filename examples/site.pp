include apache

class { 'cobbler':
  dhcp_interfaces => 'eth1',
  domain          => 'cisco.com',
  server_ip       => '10.0.0.1',
  next_server_ip  => '10.0.0.1',
  nameservers     => '10.0.0.1',
}

cobbler::add_distro { 'precise-mini':
  arch    => 'x86_64',
  isolink => 'http://archive.ubuntu.com/ubuntu/dists/precise/main/installer-amd64/current/images/netboot/mini.iso',
}

cobblerprofile { 'precise-mini':
  ensure      => present,
  distro      => 'precise-mini',
  nameservers => $cobbler::nameservers,
  kickstart   => '/etc/cobbler/preseed/cisco-preseed',
}

package { 'yum-utils':
  ensure => installed,
  before => Cobblerprofile['precise-mini'],
}

cobblersystem { 'precise-host':
  ensure          => present,
  profile         => 'precise-mini',
  interfaces      => { 'eth0' => {
                         ip_address => '10.0.0.2',
                         mac_address => '00:50:56:39:41:E7',
                         netmask    => '255.255.255.0',
                       },

  },
  nameservers    => '10.0.0.1',
  netboot        => true,
  kopts          => "netcfg/disable_autoconfig=true netcfg/dhcp_failed=true netcfg/confirm_static=true partman-auto/disk=/dev/sda",
  hostname       => 'foo.cisco.com',
  require        => Service[$cobbler::service_name],
  power_address  => '10.0.0.202',
  power_user     => 'don',
  power_password => 'mypass',
  power_id       => 'randomid',
}
