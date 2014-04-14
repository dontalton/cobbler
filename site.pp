include apache

class { 'cobbler':
  manage_dhcp     => '1',
  manage_dns      => '1',
  dhcp_interfaces => 'eth1',
  dhcp_option     => 'dnsmasq',
  domain          => 'cisco.com',
  dhcp_use_isc    => false,
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
  interfaces => { 'eth1' => {
                    mac_address      => '08:00:27:4C:54:A1',
                    ip_address       => '10.0.0.2',
                    netmask          => '255.255.255.0',
                  },
                  'eth2' => {
                    mac_address      => '08:00:27:12:C6:8A',
                    ip_address       => '0.0.0.0',
                    netmask          => '255.255.255.0',
                  },
  },
  netboot    => true,
  hostname   => 'ubuntu.cisco.com',
  require    => Service[$cobbler::service_name],
}
