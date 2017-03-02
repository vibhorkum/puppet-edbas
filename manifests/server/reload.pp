# PRIVATE CLASS: do not use directly
class edbas::server::reload {
  $service_name   = $edbas::server::service_name
  $service_status = $edbas::server::service_status
  $service_reload = $edbas::server::service_reload

  exec { 'edbas_reload':
    path        => '/usr/bin:/usr/sbin:/bin:/sbin',
    command     => $service_reload,
    onlyif      => $service_status,
    refreshonly => true,
    require     => Class['edbas::server::service'],
  }
}
