# PRIVATE CLASS: do not call directly
class edbas::server::service {
  $service_ensure   = $edbas::server::service_ensure
  $service_enable   = $edbas::server::service_enable
  $service_manage   = $edbas::server::service_manage
  $service_name     = $edbas::server::service_name
  $service_provider = $edbas::server::service_provider
  $service_status   = $edbas::server::service_status
  $user             = $edbas::server::user
  $port             = $edbas::server::port
  $default_database = $edbas::server::default_database

  anchor { 'edbas::server::service::begin': }

  if $service_manage {

    service { 'edbasd':
      ensure    => $service_ensure,
      enable    => $service_enable,
      name      => $service_name,
      provider  => $service_provider,
      hasstatus => true,
      status    => $service_status,
    }

    if $service_ensure == 'running' {
      # This blocks the class before continuing if chained correctly, making
      # sure the service really is 'up' before continuing.
      #
      # Without it, we may continue doing more work before the database is
      # prepared leading to a nasty race condition.
      edbas::validate_db_connection { 'validate_service_is_running':
        run_as          => $user,
        database_name   => $default_database,
        database_port   => $port,
        sleep           => 1,
        tries           => 60,
        create_db_first => false,
        require         => Service['edbasd'],
        before          => Anchor['edbas::server::service::end']
      }
    }
  }

  anchor { 'edbas::server::service::end': }
}
