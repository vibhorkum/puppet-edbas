# This class installs the PL/Python procedural language for edbas. See
# README.md for more details.
class edbas::server::plpython(
  $package_ensure = 'present',
  $package_name   = $edbas::server::plpython_package_name,
) {
  package { 'edbas-plpython':
    ensure => $package_ensure,
    name   => $package_name,
    tag    => 'edbas',
  }

  anchor { 'edbas::server::plpython::start': }->
  Class['edbas::server::install']->
  Package['edbas-plpython']->
  Class['edbas::server::service']->
  anchor { 'edbas::server::plpython::end': }

}
