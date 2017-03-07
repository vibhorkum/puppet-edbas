# PRIVATE CLASS: do not use directly
class edbas::params inherits edbas::globals {
  $version                    = $edbas::globals::globals_version
  $postgis_version            = $edbas::globals::globals_postgis_version
  $listen_addresses           = ''
  $port                       = 5444
  $log_line_prefix            = '%t '
  $ip_mask_deny_postgres_user = '0.0.0.0/0'
  $ip_mask_allow_all_users    = '127.0.0.1/32'
  $ipv4acls                   = []
  $ipv6acls                   = []
  $encoding                   = $edbas::globals::encoding
  $locale                     = $edbas::globals::locale
  $service_ensure             = 'running'
  $service_enable             = true
  $service_manage             = true
  $service_restart_on_change  = true
  $service_provider           = $edbas::globals::service_provider
  $manage_pg_hba_conf         = pick($manage_pg_hba_conf, true)
  $manage_pg_ident_conf       = pick($manage_pg_ident_conf, true)
  $manage_recovery_conf       = pick($manage_recovery_conf, false)
  $package_ensure             = 'present'
  $link_pg_config             = true
  $user                       = pick($user, 'enterprisedb')
  $group                      = pick($group, 'enterprisedb')
  $needs_initdb               = pick($needs_initdb, true)

  # basic EDB settings for bin,data,log and config directory
  $version_parts              = split($version, '[.]')
  $package_version            = "${version_parts[0]}${version_parts[1]}"
  $service_name               = pick($service_name,"ppas-${version}")
  $bindir                     = pick($bindir, "/usr/ppas-${version}/bin")
  $datadir                    = pick($datadir, "/var/lib/ppas/${version}/data")
  $logdir                     = pick($logdir, "${datadir}/pg_log")
  $confdir                    = pick($confdir, $datadir)
  $psql_path                  = pick($psql_path, "${bindir}/psql")
  $pg_isready                 = pick($pg_isready, "${bindir}/pg_isready")
  $perl_package_name          = pick($perl_package_name, 'perl-DBD-Pg')
  $python_package_name        = pick($python_package_name, 'python-psycopg2')

  # EDB Bart settings
  $bart_version               = $edbas::globals::bart_version
  $edb_bart_version           = pick($bart_version,'1.1')
  $bart_version_parts         = split($edb_bart_version,'[.]')
  $bart_version_major         = "${bart_version_parts[0]}${bart_version_parts[1]}" 
  if ($edb_bart_version == '1.1'){
     $bart_package_name       = pick($bart_package_name,"edb-bart")
   } else {
     $bart_package_name       = pick($bart_backpage_name,"edb-bart${bart_version_major}")
   }
  $bart_bindir                = pick($bart_bindir,"/usr/edb-bart-${bart_version}/bin")
  $bart_confdir               = pick($bart_confdir,"/usr/edb-bart-${bart_version}/etc")

  # EDB EFM settings
  $efm_version                = $edbas::globals::efm_version
  $edb_efm_version            = pick($efm_version,'2.0')
  $efm_version_parts          = split($edb_efm_version,'[.]')
  $efm_version_major          = "${efm_version_parts[0]}${efm_version_parts[1]}" 
  $efm_package_name           = pick($efm_backpage_name,"efm${efm_version_major}")
  $efm_bindir                 = pick($efm_bindir,"/usr/efm-${efm_version}/bin")
  $efm_confdir                = pick($efm_confdir,"/etc/efm-${efm_version}")

  if $edbas::globals::postgis_package_name {
     $postgis_package_name = $edbas::globals::postgis_package_name
   } else {
     $postgis_package_name = "ppas${package_version}-postgis"
   }


  # EDB Package names 
  $client_package_name        = pick($client_package_name, "ppas${package_version}-server-client")
  $server_package_name        = pick($server_package_name, "ppas${package_version}-server")
  $contrib_package_name       = pick($contrib_package_name,"ppas${package_version}-server-contrib")
  $devel_package_name         = pick($devel_package_name, "ppas${package_version}-devel")
  $java_package_name          = pick($java_package_name, "ppas${package_version}-jdbc")
  $docs_package_name          = pick($docs_package_name, "ppas${package_version}-server-docs")
  $plperl_package_name        = pick($plperl_package_name, "ppas${package_version}-server-plperl")
  $plpython_package_name      = pick($plpython_package_name, "ppas${package_version}-server-plpython")
   
  # verify the OS Version and according change the service command.
  # from version 7.0, RHEL/CentOS has systemctl 
  $os_major_release = 0 + $::operatingsystemmajrelease  
  if ($os_major_release > 6) {
      $service_reload             = "systemctl reload ${service_name}"
     $service_status = pick($service_status, "systemctl status ${service_name} | /bin/grep -q 'Active: active (running)'")
  } else { 
      $service_status = pick($service_status, "/etc/init.d/${service_name} status | /bin/grep -q '${service_name} is running'")
      $service_reload             = "service ${service_name} reload"
  } 

   # making sure mandatory parameters have been passed
   $err_prefix = "Module ${module_name} does not provide defaults for osfamily: ${::osfamily} operatingsystem: ${::operatingsystem}; please specify a value for ${module_name}::globals::"
   if ($needs_initdb == undef) { fail("${err_prefix}needs_initdb") }
   if ($service_name == undef) { fail("${err_prefix}service_name") }
   if ($client_package_name == undef) { fail("${err_prefix}client_package_name") }
   if ($server_package_name == undef) { fail("${err_prefix}server_package_name") }
   if ($bindir == undef) { fail("${err_prefix}bindir") }
   if ($datadir == undef) { fail("${err_prefix}datadir") }
   if ($confdir == undef) { fail("${err_prefix}confdir") }

  $validcon_script_path = pick($validcon_script_path, '/usr/local/bin/validate_ppas_connection.sh')
  $initdb_path          = pick($initdb_path, "${bindir}/initdb")
  $pg_hba_conf_path     = pick($pg_hba_conf_path, "${confdir}/pg_hba.conf")
  $pg_hba_conf_defaults = pick($pg_hba_conf_defaults, true)
  $pg_ident_conf_path   = pick($pg_ident_conf_path, "${confdir}/pg_ident.conf")
  $postgresql_conf_path = pick($postgresql_conf_path, "${confdir}/postgresql.conf")
  $recovery_conf_path   = pick($recovery_conf_path, "${datadir}/recovery.conf")
  $default_database     = pick($default_database, 'edb')
}
