# This class installs the PL/Perl procedural language for edbas. See
# README.md for more details.
class edbas::server::plperl(
  $package_ensure = 'present',
  $package_name   = $edbas::server::plperl_package_name
) {
  package { 'edbas-plperl':
    ensure => $package_ensure,
    name   => $package_name,
    tag    => 'edbas',
  }

  anchor { 'edbas::server::plperl::start': }->
  Class['edbas::server::install']->
  Package['edbas-plperl']->
  Class['edbas::server::service']->
  anchor { 'edbas::server::plperl::end': }

}
