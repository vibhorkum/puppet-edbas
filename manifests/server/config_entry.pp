# Manage a edbas.conf entry. See README.md for more details.
define edbas::server::config_entry (
  $ensure = 'present',
  $value  = undef,
  $path   = false
) {
  $postgresql_conf_path = $edbas::server::postgresql_conf_path

  $target = $path ? {
    false   => $postgresql_conf_path,
    default => $path,
  }

  Exec {
    logoutput => 'on_failure',
  }

  case $name {
    /data_directory|hba_file|ident_file|include|listen_addresses|port|max_connections|superuser_reserved_connections|unix_socket_directory|unix_socket_group|unix_socket_permissions|bonjour|bonjour_name|ssl|ssl_ciphers|shared_buffers|max_prepared_transactions|max_files_per_process|shared_preload_libraries|wal_level|wal_buffers|archive_mode|max_wal_senders|hot_standby|logging_collector|silent_mode|track_activity_query_size|autovacuum_max_workers|autovacuum_freeze_max_age|max_locks_per_transaction|max_pred_locks_per_transaction|restart_after_crash|lc_messages|lc_monetary|lc_numeric|lc_time|log_min_duration_statement/: {
      if $edbas::server::service_restart_on_change {
        Postgresql_conf {
          notify => Class['edbas::server::service'],
          before => Class['edbas::server::reload'],
        }
      } else {
        Postgresql_conf {
            before => [
                Class['edbas::server::service'],
                Class['edbas::server::reload'],
            ],
        }
      }
    }

    default: {
      Postgresql_conf {
        notify => Class['edbas::server::reload'],
      }
    }
  }

  # We have to handle ports and the data directory in a weird and
  # special way.  On early Debian and Ubuntu and RHEL we have to ensure
  # we stop the service completely. On RHEL 7 we either have to create
  # a systemd override for the port or update the sysconfig file, but this
  # is managed for us in edbas::server::config.
  if $::operatingsystem == 'Debian' or $::operatingsystem == 'Ubuntu' {
    if $name == 'port' and ( $::operatingsystemrelease =~ /^6/ or $::operatingsystemrelease =~ /^10\.04/ ) {
        exec { "edbas_stop_${name}":
          command => "service ${::edbas::server::service_name} stop",
          onlyif  => "service ${::edbas::server::service_name} status",
          unless  => "grep 'port = ${value}' ${::edbas::server::postgresql_conf_path}",
          path    => '/usr/sbin:/sbin:/bin:/usr/bin:/usr/local/bin',
          before  => edbas_conf[$name],
        }
    }
    elsif $name == 'data_directory' {
      exec { "edbas_stop_${name}":
        command => "service ${::edbas::server::service_name} stop",
        onlyif  => "service ${::edbas::server::service_name} status",
        unless  => "grep \"data_directory = '${value}'\" ${::edbas::server::postgresql_conf_path}",
        path    => '/usr/sbin:/sbin:/bin:/usr/bin:/usr/local/bin',
        before  => edbas_conf[$name],
      }
    }
  }
  if $::osfamily == 'RedHat' {
    if ! ($::operatingsystemrelease =~ /^7/ or $::operatingsystem == 'Fedora') {
      if $name == 'port' {
        # We need to force edbas to stop before updating the port
        # because puppet becomes confused and is unable to manage the
        # service appropriately.
        exec { "edbas_stop_${name}":
          command => "service ${::edbas::server::service_name} stop",
          onlyif  => "service ${::edbas::server::service_name} status",
          unless  => "grep 'PGPORT=${value}' /etc/sysconfig/pgsql/edbas",
          path    => '/sbin:/bin:/usr/bin:/usr/local/bin',
          require => File['/etc/sysconfig/pgsql/edbas'],
        } ->
        augeas { 'override PGPORT in /etc/sysconfig/pgsql/edbas':
          lens    => 'Shellvars.lns',
          incl    => '/etc/sysconfig/pgsql/*',
          context => '/files/etc/sysconfig/pgsql/edbas',
          changes => "set PGPORT ${value}",
          require => File['/etc/sysconfig/pgsql/edbas'],
          notify  => Class['edbas::server::service'],
          before  => Class['edbas::server::reload'],
        }
      } elsif $name == 'data_directory' {
        # We need to force edbas to stop before updating the data directory
        # otherwise init script breaks
        exec { "edbas_${name}":
          command => "service ${::edbas::server::service_name} stop",
          onlyif  => "service ${::edbas::server::service_name} status",
          unless  => "grep 'PGDATA=${value}' /etc/sysconfig/pgsql/edbas",
          path    => '/sbin:/bin:/usr/bin:/usr/local/bin',
          require => File['/etc/sysconfig/pgsql/edbas'],
        } ->
        augeas { 'override PGDATA in /etc/sysconfig/pgsql/edbas':
          lens    => 'Shellvars.lns',
          incl    => '/etc/sysconfig/pgsql/*',
          context => '/files/etc/sysconfig/pgsql/edbas',
          changes => "set PGDATA ${value}",
          require => File['/etc/sysconfig/pgsql/edbas'],
          notify  => Class['edbas::server::service'],
          before  => Class['edbas::server::reload'],
        }
      }
    }
  }

  case $ensure {
    /present|absent/: {
      Postgresql_conf { $name:
        ensure  => $ensure,
        target  => $target,
        value   => $value,
        require => Class['edbas::server::initdb'],
      }
    }

    default: {
      fail("Unknown value for ensure '${ensure}'.")
    }
  }
}
