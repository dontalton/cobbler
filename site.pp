include apache

class { 'cobbler':
  manage_dhcp     => '1',
  manage_dns      => '1',
  dhcp_interfaces => 'eth1',
  dhcp_option     => 'dnsmasq',
  domain          => 'cisco.com',
  dhcp_use_isc    => false,
}

cobbler::add_distro { 'CentOS-6.5-x86_64':
  arch    => 'x86_64',
  isolink => 'http://localhost/CentOS-6.5-x86_64-netinstall.iso',
  distro_os => 'rhel',
}

cobbler::add_distro { 'debian':
  arch => 'x86_64',
  isolink => 'http://localhost/ubunt-server-precise-mini.iso',
  distro_os => 'debian',
}

cobblerrepo { 'PuppetLabs-6-x86_64-deps':
  ensure         => present,
  arch           => 'x86_64',
  mirror         => 'http://yum.puppetlabs.com/el/6/dependencies/x86_64',
  mirror_locally => false,
  priority       => 99,
  require        => [ Service[$cobbler::service_name], Service[$cobbler::apache_service] ],
}

cobblerprofile { 'CentOS-6.5-x86_64':
  ensure      => present,
  distro      => 'CentOS-6.5-x86_64',
  nameservers => $cobbler::nameservers,
  repos       => ['PuppetLabs-6-x86_64-deps', 'PuppetLabs-6-x86_64-products' ],
  kickstart   => '/var/lib/cobbler/kickstarts/default.ks',
}

package { 'yum-utils':
  ensure => installed,
  before => Cobblerprofile['CentOS-6.5-x86_64'],
}

cobblersystem { 'somehost':
  ensure     => present,
  profile    => 'CentOS-6.5-x86_64',
  interfaces => { 'eth0' => {
                    mac_address      => 'AA:BB:CC:DD:EE:F0',
                    interface_type   => 'bond_slave',
                    interface_master => 'bond0',
                    static           => true,
                    management       => true,
                  },
                  'eth1' => {
                    mac_address      => 'AA:BB:CC:DD:EE:F1',
                    interface_type   => 'bond_slave',
                    interface_master => 'bond0',
                    static           => true,
                  },
                  'bond0' => {
                    ip_address     => '192.168.1.210',
                    netmask        => '255.255.255.0',
                    static         => true,
                    interface_type => 'bond',
                    bonding_opts   => 'miimon=300 mode=1 primary=em1',
                  },
  },
  netboot    => true,
  gateway    => '192.168.1.1',
  hostname   => 'somehost.example.com',
  require    => Service[$cobbler::service_name],
}
