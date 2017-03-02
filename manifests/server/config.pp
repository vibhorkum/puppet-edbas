# PRIVATE CLASS: do not call directly
class edbas::server::config {
  $ip_mask_deny_postgres_user = $edbas::server::ip_mask_deny_postgres_user
  $ip_mask_allow_all_users    = $edbas::server::ip_mask_allow_all_users
  $listen_addresses           = $edbas::server::listen_addresses
  $port                       = $edbas::server::port
  $ipv4acls                   = $edbas::server::ipv4acls
  $ipv6acls                   = $edbas::server::ipv6acls
  $pg_hba_conf_path           = $edbas::server::pg_hba_conf_path
  $pg_ident_conf_path         = $edbas::server::pg_ident_conf_path
  $postgresql_conf_path       = $edbas::server::postgresql_conf_path
  $recovery_conf_path         = $edbas::server::recovery_conf_path
  $pg_hba_conf_defaults       = $edbas::server::pg_hba_conf_defaults
  $user                       = $edbas::server::user
  $group                      = $edbas::server::group
  $version                    = $edbas::server::_version
  $manage_pg_hba_conf         = $edbas::server::manage_pg_hba_conf
  $manage_pg_ident_conf       = $edbas::server::manage_pg_ident_conf
  $manage_recovery_conf       = $edbas::server::manage_recovery_conf
  $datadir                    = $edbas::server::datadir
  $logdir                     = $edbas::server::logdir
  $service_name               = $edbas::server::service_name
  $log_line_prefix            = $edbas::server::log_line_prefix

  if ($manage_pg_hba_conf == true) {
    # Prepare the main pg_hba file
    concat { $pg_hba_conf_path:
      owner  => $user,
      group  => $group,
      mode   => '0640',
      warn   => true,
      notify => Class['edbas::server::reload'],
    }

    if $pg_hba_conf_defaults {
        Edbas::Server::Pg_hba_rule  { 'local_setting':
        database => 'all',
        user => 'all',
      }

      # Lets setup the base rules
      $local_auth_option = undef
      edbas::server::pg_hba_rule  { 'local access as postgres user':
        type        => 'local',
        user        => $user,
        auth_method => 'ident',
        auth_option => $local_auth_option,
        order       => '001',
      }
      edbas::server::pg_hba_rule  { 'local access to database with same name':
        type        => 'local',
        auth_method => 'ident',
        auth_option => $local_auth_option,
        order       => '002',
      }
      edbas::server::pg_hba_rule  { 'allow localhost TCP access to postgresql user':
        type        => 'host',
        user        => $user,
        address     => '127.0.0.1/32',
        auth_method => 'md5',
        order       => '003',
      }
      edbas::server::pg_hba_rule  { 'deny access to postgresql user':
        type        => 'host',
        user        => $user,
        address     => $ip_mask_deny_postgres_user,
        auth_method => 'reject',
        order       => '004',
      }

      edbas::server::pg_hba_rule  { 'allow access to all users':
        type        => 'host',
        address     => $ip_mask_allow_all_users,
        auth_method => 'md5',
        order       => '100',
      }
      edbas::server::pg_hba_rule  { 'allow access to ipv6 localhost':
        type        => 'host',
        address     => '::1/128',
        auth_method => 'md5',
        order       => '101',
      }
    }

    # ipv4acls are passed as an array of rule strings, here we transform
    # them into a resources hash, and pass the result to create_resources
    $ipv4acl_resources = edbas_acls_to_resources_hash($ipv4acls,
    'ipv4acls', 10)
    create_resources('edbas::server::pg_hba_rule ', $ipv4acl_resources)


    # ipv6acls are passed as an array of rule strings, here we transform
    # them into a resources hash, and pass the result to create_resources
    $ipv6acl_resources = edbas_acls_to_resources_hash($ipv6acls,
    'ipv6acls', 102)
    create_resources('Edbas::Server::Pg_hba_rule ', $ipv6acl_resources)
  }

  # We must set a "listen_addresses" line in the postgresql.conf if we
  # want to allow any connections from remote hosts.
  edbas::server::config_entry { 'listen_addresses':
    value => $listen_addresses,
  }
  edbas::server::config_entry { 'port':
    value => $port,
  }
  edbas::server::config_entry { 'data_directory':
    value => $datadir,
  }
  if $logdir {
    edbas::server::config_entry { 'log_directory':
      value => $logdir,
    }

  }
  # Allow timestamps in log by default
  if $log_line_prefix {
    edbas::server::config_entry {'log_line_prefix':
      value => $log_line_prefix,
    }
  }



  if ($manage_pg_ident_conf == true) {
    concat { $pg_ident_conf_path:
      owner  => $user,
      group  => $group,
      force  => true, # do not crash if there is no pg_ident_rules
      mode   => '0640',
      warn   => true,
      notify => Class['edbas::server::reload'],
    }
  }

  if ($manage_recovery_conf == true) {
    concat { $recovery_conf_path:
      owner  => $user,
      group  => $group,
      force  => true, # do not crash if there is no recovery conf file
      mode   => '0640',
      warn   => true,
      notify => Class['edbas::server::reload'],
    }
  }

}
