include apache

class { 'cobbler':
  manage_dhcp     => '1',
  manage_dns      => '1',
  dhcp_interfaces => 'eth1',
  dhcp_option     => 'dnsmasq',
  domain          => 'cisco.com',
  dhcp_use_isc    => false,
  server_ip       => '10.0.0.1',
  next_server_ip  => '10.0.0.1',
  nameservers     => '10.0.0.1',
}

cobbler::add_distro { 'precise-mini':
  arch    => 'x86_64',
  isolink => 'http://10.0.0.50/ubuntu-server-precise-mini.iso',
}

cobblerprofile { 'precise-mini':
  ensure      => present,
  distro      => 'precise-mini',
  nameservers => $cobbler::nameservers,
  kickstart   => '/var/lib/cobbler/kickstarts/ubuntu-server.preseed',
}

package { 'yum-utils':
  ensure => installed,
  before => Cobblerprofile['precise-mini'],
}

cobblersystem { 'precise-host':
  ensure     => present,
  profile    => 'precise-mini',
  interfaces => { 'eth0' => {
                    ip_address => '10.0.0.2',
                    mac_address => '08:00:27:B0:3A:E0',
                    netmask   => '255.255.255.0',
                  },
                  'eth1' => {
                    ip_address => '10.0.0.3',
                    mac_address => '08:00:27:49:DE:4A',
                    netmask => '255.255.255.0',
                  },
  },
  netboot    => true,
  hostname   => 'foo.cisco.com',
  require    => Service[$cobbler::service_name],
}
