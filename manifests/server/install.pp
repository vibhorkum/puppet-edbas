# PRIVATE CLASS: do not call directly
class edbas::server::install {
  $package_ensure      = $edbas::server::package_ensure
  $package_name        = $edbas::server::package_name
  $client_package_name = $edbas::server::client_package_name

  $_package_ensure = $package_ensure ? {
    true     => 'present',
    false    => 'purged',
    'absent' => 'purged',
    default => $package_ensure,
  }

  package { 'edbas-server':
    ensure => $_package_ensure,
    name   => $package_name,

    # This is searched for to create relationships with the package repos, be
    # careful about its removal
    tag    => 'edbas',
  }

}
