# This class installs the edbas jdbc connector. See README.md for more
# details.
class edbas::lib::java (
  $package_name   = $edbas::params::java_package_name,
  $package_ensure = 'present'
) inherits edbas::params {

  validate_string($package_name)

  package { 'edbas-jdbc':
    ensure => $package_ensure,
    name   => $package_name,
    tag    => 'edbas',
  }

}
