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
  isolink => 'http://10.0.0.50/ubuntu-server-precise-mini.iso',
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
  ensure     => present,
  profile    => 'precise-mini',
  interfaces => { 'eth1' => {
                    ip_address => '10.0.0.2',
                    mac_address => '00:50:56:39:41:E7',
                    netmask    => '255.255.255.0',
                    gateway    => '10.0.0.1',
                  },

  },
  nameservers => '8.8.8.8',
  netboot    => true,
  kopts      => "netcfg/disable_autoconfig=true netcfg/dhcp_failed=true netcfg/confirm_static=true partman-auto/disk=${bootdisk2}",
  hostname   => 'foo.cisco.com',
  require    => Service[$cobbler::service_name],
  power_address => '1.1.1.1',
  power_user => 'don',
  power_password => 'mypass',
  power_id => 'randomid',
}
