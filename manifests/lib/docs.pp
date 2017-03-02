# This class installs the edbas-docs See README.md for more
# details.
class edbas::lib::docs (
  $package_name   = $edbas::params::docs_package_name,
  $package_ensure = 'present',
) inherits edbas::params {

  validate_string($package_name)

  package { 'edbas-docs':
    ensure => $package_ensure,
    name   => $package_name,
    tag    => 'edbas',
  }

}
