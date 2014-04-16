include apache

class { 'cobbler':
  manage_dhcp     => '1',
  manage_dns      => '1',
  dhcp_interfaces => 'eth1',
  dhcp_option     => 'dnsmasq',
  domain          => 'cisco.com',
  dhcp_use_isc    => false,
  server_ip => '10.0.0.1',
  next_server_ip => '10.0.0.1',
}

cobbler::add_distro { 'precise-x86_64':
  arch => 'x86_64',
  isolink => 'http://localhost/ubunt-server-precise-mini.iso',
  distro_os => 'debian',
}

cobblerprofile { 'precise-x86_64':
  ensure      => present,
  distro      => 'precise-x86_64',
  nameservers => $cobbler::nameservers,
  kickstart   => '/var/lib/cobbler/kickstarts/ubuntu-server.preseed',
}

package { 'yum-utils':
  ensure => installed,
  before => Cobblerprofile['precise-x86_64'],
}

cobblersystem { 'precise-host':
  ensure     => present,
  profile    => 'precise-x86_64',
  interfaces => { 'eth0' => {
                    ip_address => '10.0.0.2',
                    mac_address => '08:00:27:B0:3A:E0',
                    netmask   => '255.255.255.0',
                  },
                  'eth1' => {
                    ip_address => '10.0.0.3',
                    mac_address => '',
                    netmask => '255.255.255.0',
                  },
  },
  netboot    => true,
  hostname   => 'foo.cisco.com',
  require    => Service[$cobbler::service_name],
}
