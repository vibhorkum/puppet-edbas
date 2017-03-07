# PRIVATE CLASS: do not call directly
class edbas::bart::install {
  $package_ensure      = $edbas::bart::package_ensure
  $bart_package_name   = $edbas::bart::bart_package_name
  $client_package_name = $edbas::bart::client_package_name

  $_package_ensure = $package_ensure ? {
    true     => 'present',
    false    => 'purged',
    'absent' => 'purged',
    default => $package_ensure,
  }

  package { 'edbas-bart':
    ensure => $_package_ensure,
    name   => $bart_package_name,

    # This is searched for to create relationships with the package repos, be
    # careful about its removal
    tag    => 'edbas-tools',
  }

}
