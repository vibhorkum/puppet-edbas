# This installs a edbas server. See README.md for more details.
class edbas::bart (
  $postgres_password          = 'edb',
  $package_name               = $edbas::params::server_package_name,
  $client_package_name        = $edbas::params::client_package_name,
  $package_ensure             = $edbas::params::package_ensure,
  $service_ensure             = $edbas::params::service_ensure,
  $service_enable             = $edbas::params::service_enable,
  $service_manage             = $edbas::params::service_manage,
  $service_name               = $edbas::params::service_name,
  $service_restart_on_change  = $edbas::params::service_restart_on_change,
  $service_provider           = $edbas::params::service_provider,
  $service_reload             = $edbas::params::service_reload,
  $service_status             = $edbas::params::service_status,
  $default_database           = $edbas::params::default_database,
  $default_connect_settings   = $edbas::globals::default_connect_settings,
  $ip_mask_deny_postgres_user = $edbas::params::ip_mask_deny_postgres_user,
  $ip_mask_allow_all_users    = $edbas::params::ip_mask_allow_all_users,
  $ipv4acls                   = $edbas::params::ipv4acls,
  $ipv6acls                   = $edbas::params::ipv6acls,
  $psql_path                  = $edbas::params::psql_path,
  $pg_hba_conf_path           = $edbas::params::pg_hba_conf_path,
  $pg_ident_conf_path         = $edbas::params::pg_ident_conf_path,
  $pg_conf_path               = $edbas::params::pg_conf_path,
  $recovery_conf_path         = $edbas::params::recovery_conf_path,
  $datadir                    = $edbas::params::datadir,
  $xlogdir                    = $edbas::params::xlogdir,
  $logdir                     = $edbas::params::logdir,
  $log_line_prefix            = $edbas::params::log_line_prefix,
  $pg_hba_conf_defaults       = $edbas::params::pg_hba_conf_defaults,
  $user                       = $edbas::params::user,
  $group                      = $edbas::params::group,
  $needs_initdb               = $edbas::params::needs_initdb,
  $encoding                   = $edbas::params::encoding,
  $locale                     = $edbas::params::locale,
  $manage_pg_hba_conf         = $edbas::params::manage_pg_hba_conf,
  $manage_pg_ident_conf       = $edbas::params::manage_pg_ident_conf,
  # backup and recovery parameters
  $bart_package_name          = $edbas::params::bart_package_name,
  $bart_bindir                = $edbas::params::bart_bindir,
  $bart_confdir               = $edbas::params::bart_confdir,
  #Deprecated
  $version                    = undef,
) inherits edbas::params {
  $backup_tool = 'edbas::bart'

  alert (": psq_path => ${psql_path}")
  if $version != undef {
    warning('Passing "version" to edbas::server is deprecated; please use edbas::globals instead.')
    $_version = $version
  } else {
    $_version = $edbas::params::version
  }


  anchor { "${backup_tool}::start": }->
  class { "${backup_tool}::install": }->
  anchor { "${backup_tool}::end": }
}
