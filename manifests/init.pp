# Class: cobbler
#
# This class manages Cobbler
# https://fedorahosted.org/cobbler/
#
# Parameters:
#
#   - $service_name [type: string]
#     Name of the cobbler service, defaults to 'cobblerd'.
#
#   - $package_ensure [type: string]
#     Defaults to 'present', buy any version can be set
#
#   - $distro_path [type: string]
#     Defines the location on disk where distro files will be
#     stored. Contents of the ISO images will be copied over
#     in these directories, and also kickstart files will be
#     stored. Defaults to '/distro'
#
#   - $manage_dhcp [type: bool]
#     Wether or not to manage ISC DHCP.
#
#   - $manage_dns [type: string]
#     Wether or not to manage DNS
#
#   - $dns_option [type: string]
#     Which DNS deamon to manage - Bind or dnsmasq. If dnsmasq,
#     then dnsmasq has to be used for DHCP too.
#
#   - $domain [type: string]
#     The domain name to use. Eg. cisco.com
#
#   - $dhcp_option [type: string]
#     Which dhcp server to use
#     Just use dnsmasq.
#
#   - $manage_tftpd [type: bool]
#     Manage the tftpd daemon.
#
#   - $tftpd_package [type:string]
#     Which TFTP daemon to use.
#
#   - $server_ip [type: string]
#     IP address of the cobbler server.
#
#   - $next_server_ip [type: string]
#     Next Server in cobbler config.
#
#   - $nameserversa [type: array]
#     Nameservers for kickstart files to put in resolv.conf upon
#     installation.
#
#   - $dhcp_interfaces [type: array]
#     Interface for DHCP to listen on.
#
#   - $defaultrootpw [type: string]
#     Hash of root password for kickstart files.
#
#   - $apache_service [type: string]
#     Name of the apache service.
#
#   - $allow_access [type: string]
#     For what IP addresses/hosts will access to cobbler_api be granted.
#     Default is for server_ip, ::ipaddress and localhost
#
#   - $purge_distro  [type: bool]
#   - $purge_repo    [type: bool]
#   - $purge_profile [type: bool]
#   - $purge_system  [type: bool]
#     Decides wether or not to purge (remove) from cobbler distro,
#     repo, profiles and systems which are not managed by puppet.
#     Default is true.
#
#   - $apache_conf_dir [type: string]
#     Path to Apache's discretionary config files.
#
#   - $dhcp_package_isc [type: string]
#    The package name of the isc dhcp server
#    Should be removed.
#
#   - $dhcp_package_dnsmasq [type: string]
#     The package name od the dnsmasq server
#     Should be removed.
#
#   - $tftpd_package [type: string]
#     The package name of tftpd
#
#   - $webroot [type: string]
#     The path to cobbler in the Apache dir.
#     eg /var/www/cobbler
#
#   - $diskpart [type: hash?]
#     Something from cisco that probably needs further work.
#

class cobbler (
  $service_name           = $cobbler::params::service_name,
  $package_ensure         = $cobbler::params::package_ensure,
  $distro_path            = $cobbler::params::distro_path,
  $manage_dhcp            = $cobbler::params::manage_dhcp,
  $manage_dns             = $cobbler::params::manage_dns,
  $dns_option             = $cobbler::params::dns_option,
  $domain                 = $cobbler::params::domain,
  $dhcp_range             = $cobbler::params::dhcp_range,
  $dhcp_option            = $cobbler::params::dhcp_option,
  $dhcp_subnet            = $cobbler::params::dhcp_subnet,
  $dhcp_netmask           = $cobbler::params::dhcp_netmask,
  $dhcp_dns_server        = $cobbler::params::dhcp_dns_server,
  $dhcp_option_routers    = $cobbler::params::dhcp_option_routers,
  $dhcp_option_subnet     = $cobbler::params::dhcp_option_subnet,
  $dhcp_server_identifier = $cobbler::params::dhcp_server_identifier,
  $manage_tftpd           = $cobbler::params::manage_tftpd,
  $tftpd_package          = $cobbler::params::tftpd_package,
  $server_ip              = $cobbler::params::server_ip,
  $next_server_ip         = $cobbler::params::next_server_ip,
  $nameservers            = $cobbler::params::nameservers,
  $dhcp_interfaces        = $cobbler::params::dhcp_interfaces,
  $defaultrootpw          = $cobbler::params::defaultrootpw,
  $apache_service         = $cobbler::params::apache_service,
  $allow_access           = $cobbler::params::allow_access,
  $purge_distro           = $cobbler::params::purge_distro,
  $purge_repo             = $cobbler::params::purge_repo,
  $purge_profile          = $cobbler::params::purge_profile,
  $purge_system           = $cobbler::params::purge_system,
  $apache_conf_dir        = $cobbler::params::apache_conf_dir,
  $dhcp_package_isc       = $cobbler::params::dhcp_package_isc,
  $dhcp_package_dnsmasq   = $cobbler::params::dhcp_package_dnsmasq,
  $tftpd_package          = $cobbler::params::tftpd_package,
  $webroot                = $cobbler::params::webroot,
  $diskpart               = $cobbler::params::diskpart,
  # cruft to populate the cisco preseed. this needs to be moved to p-coi
  $diskpart,
  $expert_disk,
  $boot_disk,
  $root_part_size,
  $enable_var,
  $var_part_size,
  $enable_var_space,
  $ntp_server,
  $time_zone,
  $admin_user,
  $password_crypted,
  $packages,
  $server_ip,
  $openstack_repo_location,
  $openstack_release,
  $pocket,
  $supplemental_repo,
  $late_command,

  

) inherits cobbler::params {

  # require apache modules
  require apache::mod::wsgi
  require apache::mod::proxy
  require apache::mod::proxy_http

  # install section
  if $tftpd_package == 'in_tftpd' {
    package { $tftpd_package:
      ensure => present,
      before => Package['syslinux'],
    }
  }

  package { 'syslinux':
    ensure => present,
  }

  package { 'cobbler' :
    ensure  => $package_ensure,
    require => Package['syslinux'],
  }

  service { $service_name :
    ensure  => running,
    enable  => true,
    require => Package['cobbler'],
  }

  # file defaults
  File {
    ensure => file,
    owner  => root,
    group  => root,
    mode   => '0644',
  }

  file { "${apache_conf_dir}/proxy_cobbler.conf":
    content => template('cobbler/proxy_cobbler.conf.erb'),
    notify  => Service[$apache_service],
  }

  file { $distro_path :
    ensure => directory,
    mode   => '0755',
  }

  file { "${distro_path}/kickstarts" :
    ensure => directory,
    mode   => '0755',
  }

  file { '/etc/cobbler/settings':
    content => template('cobbler/settings.erb'),
    require => Package['cobbler'],
    notify  => Service[$service_name],
  }

  file { '/etc/cobbler/modules.conf':
    content => template('cobbler/modules.conf.erb'),
    require => Package['cobbler'],
    notify  => Service[$service_name],
  }

  file { "${apache_conf_dir}/distros.conf":
    content => template('cobbler/distros.conf.erb'),
  }

  file { "${apache_conf_dir}/cobbler.conf":
    content => template('cobbler/cobbler.conf.erb'),
  }

  # purge resources
  if $purge_distro == true {
    resources { 'cobblerdistro':  purge => true, }
  }
  if $purge_repo == true {
    resources { 'cobblerrepo':    purge => true, }
  }
  if $purge_profile == true {
    resources { 'cobblerprofile': purge => true, }
  }
  if $purge_system == true {
    resources { 'cobblersystem':  purge => true, }
  }

  package { $dhcp_package_dnsmasq:
    ensure  => present,
    require => [ Package['cobbler'], Package['syslinux'] ],
  }

  file { '/etc/cobbler/dnsmasq.template':
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('cobbler/dnsmasq.template.erb'),
    require => [ Package[$dhcp_package_dnsmasq], Package['cobbler'] ],
  }

  file { '/etc/cobbler/dhcp.template':
    ensure => present,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('cobbler/dhcp.template.erb'),
    require => [ Package[$dhcp_package_dnsmasq], Package['cobbler'] ],
  }

  exec { '/usr/bin/cobbler sync':
    require => [ File['/etc/cobbler/dhcp.template'], File['/etc/cobbler/dnsmasq.template'] ],
  }

  file { '/etc/logrotate.d/cobbler_rotate':
    content => template('cobbler/cobbler_rotate.erb'),
    require => Package['cobbler'],
  }

  file { '/var/lib/cobbler/kickstarts/cisco-preseed':
    content => template('cobbler/cisco.ks.erb'),
    require => Package['cobbler'],
  }


}
