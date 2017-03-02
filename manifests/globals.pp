# Class for setting cross-class global overrides. See README.md for more
# details.
class edbas::globals (
  $client_package_name      = undef,
  $server_package_name      = undef,
  $contrib_package_name     = undef,
  $devel_package_name       = undef,
  $java_package_name        = undef,
  $docs_package_name        = undef,
  $perl_package_name        = undef,
  $plperl_package_name      = undef,
  $plpython_package_name    = undef,
  $python_package_name      = undef,
  $postgis_package_name     = undef,

  $service_name             = undef,
  $service_provider         = undef,
  $service_status           = undef,
  $default_database         = undef,

  $validcon_script_path     = undef,

  $initdb_path              = undef,
  $createdb_path            = undef,
  $psql_path                = undef,
  $pg_hba_conf_path         = undef,
  $pg_ident_conf_path       = undef,
  $edbas_conf_path     = undef,
  $recovery_conf_path       = undef,
  $default_connect_settings = {},

  $pg_hba_conf_defaults     = undef,

  $datadir                  = undef,
  $confdir                  = undef,
  $bindir                   = undef,
  $xlogdir                  = undef,
  $logdir                   = undef,
  $log_line_prefix          = undef,

  $user                     = undef,
  $group                    = undef,

  $version                  = undef,
  $postgis_version          = undef,
  $repo_proxy               = undef,
  $yum_user                 = undef,
  $yum_password             = undef,

  $needs_initdb             = undef,

  $encoding                 = undef,
  $locale                   = undef,

  $manage_pg_hba_conf       = undef,
  $manage_pg_ident_conf     = undef,
  $manage_recovery_conf     = undef,

  $manage_package_repo      = undef,
) {
  #  check if yumuser and yum password is provided or not:
   $err_prefix = "Module ${module_name} does not provide defaults for osfamily: ${::osfamily} operatingsystem: ${::operatingsystem}; please specify a value for ${module_name}::globals::"
   if ($yum_user == undef) { fail("${err_prefix}needs_user") }
   if ($yum_password == undef) { fail("${err_prefix}yum_password") }
  # We are determining this here, because it is needed by the package repo
  # class.
  $default_version = '9.5'
  $globals_version = pick($version, $default_version, 'unknown')
  if($globals_version == 'unknown') {
    fail('No preferred version defined or automatically detected.')
  }

  $default_postgis_version = $globals_version ? {
    '9.5'   => '2.2',
    default => undef,
  }
  $globals_postgis_version = $postgis_version ? {
    undef   => $default_postgis_version,
    default => $postgis_version,
  }
  #
  # Setup of the repo only makes sense globally, so we are doing this here.
  if($manage_package_repo) {
    class { 'edbas::repo':
      version => $globals_version,
      proxy   => $repo_proxy,
      yumuser => $yum_user,
      yumpassword => $yum_password,
    }
  }
}
