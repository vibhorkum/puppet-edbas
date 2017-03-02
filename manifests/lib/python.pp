# This class installs the python libs for edbas. See README.md for more
# details.
class edbas::lib::python(
  $package_name   = $edbas::params::python_package_name,
  $package_ensure = 'present'
) inherits edbas::params {

  package { 'python-psycopg2':
    ensure => $package_ensure,
    name   => $package_name,
  }

}
