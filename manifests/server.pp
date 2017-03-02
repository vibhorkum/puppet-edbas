# This installs a edbas server. See README.md for more details.
class edbas::server (
  $postgres_password          = undef,
  $package_name               = $edbas::params::server_package_name,
  $client_package_name        = $edbas::params::client_package_name,
  $package_ensure             = $edbas::params::package_ensure,
  $plperl_package_name        = $edbas::params::plperl_package_name,
  $plpython_package_name      = $edbas::params::plpython_package_name,
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
  $listen_addresses           = $edbas::params::listen_addresses,
  $port                       = $edbas::params::port,
  $ip_mask_deny_postgres_user = $edbas::params::ip_mask_deny_postgres_user,
  $ip_mask_allow_all_users    = $edbas::params::ip_mask_allow_all_users,
  $ipv4acls                   = $edbas::params::ipv4acls,
  $ipv6acls                   = $edbas::params::ipv6acls,
  $initdb_path                = $edbas::params::initdb_path,
  $createdb_path              = $edbas::params::createdb_path,
  $psql_path                  = $edbas::params::psql_path,
  $as_hba_conf_path           = $edbas::params::as_hba_conf_path,
  $as_ident_conf_path         = $edbas::params::as_ident_conf_path,
  $edbas_conf_path            = $edbas::params::edbas_conf_path,
  $recovery_conf_path         = $edbas::params::recovery_conf_path,
  $datadir                    = $edbas::params::datadir,
  $xlogdir                    = $edbas::params::xlogdir,
  $logdir                     = $edbas::params::logdir,
  $log_line_prefix            = $edbas::params::log_line_prefix,
  $as_hba_conf_defaults       = $edbas::params::as_hba_conf_defaults,
  $user                       = $edbas::params::user,
  $group                      = $edbas::params::group,
  $needs_initdb               = $edbas::params::needs_initdb,
  $encoding                   = $edbas::params::encoding,
  $locale                     = $edbas::params::locale,
  $manage_as_hba_conf         = $edbas::params::manage_as_hba_conf,
  $manage_as_ident_conf       = $edbas::params::manage_as_ident_conf,
  $manage_recovery_conf       = $edbas::params::manage_recovery_conf,

  #Deprecated
  $version                    = undef,
) inherits edbas::params {
  $as = 'edbas::server'

  alert (": psq_path => ${psql_path}")
  if $version != undef {
    warning('Passing "version" to edbas::server is deprecated; please use edbas::globals instead.')
    $_version = $version
  } else {
    $_version = $edbas::params::version
  }

  if $createdb_path != undef{
    warning('Passing "createdb_path" to edbas::server is deprecated, it can be removed safely for the same behaviour')
  }

  # Reload has its own ordering, specified by other defines
  class { "${as}::reload": require => Class["${as}::install"] }

  anchor { "${as}::start": }->
  class { "${as}::install": }->
  class { "${as}::initdb": }->
  class { "${as}::config": }->
  class { "${as}::service": }->
  class { "${as}::passwd": }->
  anchor { "${as}::end": }
}
