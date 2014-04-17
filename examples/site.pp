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
  interfaces => { 'eth1' => {
                    mac_address => '00:50:56:39:41:E7',
                    netmask    => '255.255.255.0',
                    gateway    => '10.0.0.1',
                  },

  },
  netboot    => true,
  kopts      => 'netcfg/confirm_static=true netcfg/get_ipaddress=2.5.1.254',
  hostname   => 'foo.cisco.com',
  require    => Service[$cobbler::service_name],
  power_address => '1.1.1.1',
  power_user => 'don',
  power_password => 'mypass',
  power_id => 'randomid',
}
