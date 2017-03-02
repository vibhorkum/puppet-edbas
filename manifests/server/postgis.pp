# Install the postgis edbas packaging. See README.md for more details.
class edbas::server::postgis (
  $package_name   = $edbas::params::postgis_package_name,
  $package_ensure = 'present'
) inherits edbas::params {
  validate_string($package_name)

  package { 'edbas-postgis':
    ensure => $package_ensure,
    name   => $package_name,
    tag    => 'edbas',
  }

  anchor { 'edbas::server::postgis::start': }->
  Class['edbas::server::install']->
  Package['edbas-postgis']->
  Class['edbas::server::service']->
  anchor { 'edbas::server::postgis::end': }

  if $edbas::globals::manage_package_repo {
    Class['edbas::repo'] ->
    Package['edbas-postgis']
  }
}
