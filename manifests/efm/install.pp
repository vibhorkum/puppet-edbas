# PRIVATE CLASS: do not call directly
class edbas::efm::install {
  $package_ensure      = $edbas::efm::package_ensure
  $efm_package_name    = $edbas::efm::efm_package_name
  $client_package_name = $edbas::efm::client_package_name

  $_package_ensure = $package_ensure ? {
    true     => 'present',
    false    => 'purged',
    'absent' => 'purged',
    default => $package_ensure,
  }

  package { 'edbas-efm':
    ensure => $_package_ensure,
    name   => $efm_package_name,

    # This is searched for to create relationships with the package repos, be
    # careful about its removal
    tag    => 'edbas-tools',
  }

}
