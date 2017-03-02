# This class installs edbas development libraries. See README.md for more
# details.
class edbas::lib::devel(
  $package_name   = $edbas::params::devel_package_name,
  $package_ensure = 'present',
  $link_pg_config = $edbas::params::link_pg_config
) inherits edbas::params {

  validate_string($package_name)

  package { 'edbas-devel':
    ensure => $package_ensure,
    name   => $package_name,
    tag    => 'edbas',
  }

  if $link_pg_config {
    if ( $edbas::params::bindir != '/usr/bin' and $edbas::params::bindir != '/usr/local/bin') {
      file { '/usr/bin/pg_config':
        ensure => link,
        target => "${edbas::params::bindir}/pg_config",
      }
    }
  }

}
