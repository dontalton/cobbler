# Class: cobbler::params
#
#   The cobbler default configuration settings.
#
class cobbler::params {
  case $::osfamily {
    'RedHat': {
      $service_name         = 'cobblerd'
      $apache_service       = 'httpd'
      $apache_conf_dir      = '/etc/httpd/conf.d'
      $dhcp_package_isc     = 'dhcp'
      $dhcp_package_dnsmasq = 'rhel_dnsmasq_package'
      $tftpd_package        = 'tftp-server'
    }
    'Debian': {
      $service_name         = 'cobbler'
      $apache_service       = 'apache2'
      $apache_conf_dir      = '/etc/apache2/conf.d'
      $dhcp_package_isc     = 'isc-dhcp-server'
      $dhcp_package_dnsmasq = 'dnsmasq'
      $tftpd_package        = 'tftpd'
      $tftpd_option         = 'in_tftpd'
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily} operatingsystem: ${::operatingsystem}, module ${module_name} currently only supports osfamily RedHat")
    }
  }
  $package_ensure = 'present'

  # general settings
  $next_server_ip = $::ipaddress
  $server_ip      = $::ipaddress
  $distro_path    = '/distro'
  $nameservers    = '10.0.0.1'
  $webroot        = '/var/www/cobbler'

  # default root password for kickstart files
  $defaultrootpw = 'bettergenerateityourself'

  # dhcp options
  $manage_dhcp             = 1
  $dhcp_option             = 'dnsmasq'
  $dhcp_subnet             = '2.5.1.0'
  $dhcp_netmask            = '255.255.255.0'
  $dhcp_option_routers     = '2.5.1.254'
  $dhcp_option_domain_name = 'cisco.com'
  $dhcp_option_subnet      = '255.255.255.0'
  $dhcp_server_identifier  = '2.5.1.254'
  $dhcp_range              = '2.5.1.0,static,255.255.255.0'
  $dhcp_interfaces         = 'eth0'

  # dns options
  $manage_dns = 1
  $dns_option = 'dnsmasq'

  # dns domain name
  $domain = 'test.com'

  # tftpd options
  $manage_tftpd = 1

  # puppet integration setup
  $puppet_auto_setup                     = 1
  $sign_puppet_certs_automatically       = 1
  $remove_old_puppet_certs_automatically = 1

  # access, regulated through Proxy directive
  $allow_access = "${server_ip} ${::ipaddress} 127.0.0.1"

  # purge resources that are not defined
  $purge_distro  = true
  $purge_repo    = true
  $purge_profile = true
  $purge_system  = true

  # disk partitioning
  $diskpart = []
}

