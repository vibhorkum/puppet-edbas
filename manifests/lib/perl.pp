# This class installs the perl libs for edbas. See README.md for more
# details.
class edbas::lib::perl(
  $package_name   = $edbas::params::perl_package_name,
  $package_ensure = 'present'
) inherits edbas::params {

  package { 'perl-DBD-Pg':
    ensure => $package_ensure,
    name   => $package_name,
  }

}
