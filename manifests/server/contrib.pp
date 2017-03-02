# Install the contrib edbas packaging. See README.md for more details.
class edbas::server::contrib (
  $package_name   = $edbas::params::contrib_package_name,
  $package_ensure = 'present'
) inherits edbas::params {
  validate_string($package_name)

  package { 'edbas-contrib':
    ensure => $package_ensure,
    name   => $package_name,
    tag    => 'edbas',
  }

  anchor { 'edbas::server::contrib::start': }->
  Class['edbas::server::install']->
  Package['edbas-contrib']->
  Class['edbas::server::service']->
  anchor { 'edbas::server::contrib::end': }
}
