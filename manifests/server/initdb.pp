# PRIVATE CLASS: do not call directly
class edbas::server::initdb {
  $needs_initdb = $edbas::server::needs_initdb
  $initdb_path  = $edbas::server::initdb_path
  $datadir      = $edbas::server::datadir
  $xlogdir      = $edbas::server::xlogdir
  $logdir       = $edbas::server::logdir
  $encoding     = $edbas::server::encoding
  $locale       = $edbas::server::locale
  $group        = $edbas::server::group
  $user         = $edbas::server::user
  $psql_path    = $edbas::server::psql_path
  $port         = $edbas::server::port

  # Set the defaults for the edbas_psql resource
  Edbas_psql { 
    psql_user  => $user,
    psql_group => $group,
    psql_path  => $psql_path,
    port       => $port,
  }

  # Make sure the data directory exists, and has the correct permissions.
  file { $datadir:
    ensure => directory,
    owner  => $user,
    group  => $group,
    mode   => '0700',
  }

  if($xlogdir) {
    # Make sure the xlog directory exists, and has the correct permissions.
    file { $xlogdir:
      ensure => directory,
      owner  => $user,
      group  => $group,
      mode   => '0700',
    }
  }


  if($needs_initdb) {
    # Build up the initdb command.
    #
    # We optionally add the locale switch if specified. Older versions of the
    # initdb command don't accept this switch. So if the user didn't pass the
    # parameter, lets not pass the switch at all.
    $ic_base = "${initdb_path} --encoding '${encoding}' --pgdata '${datadir}'"
    $ic_xlog = $xlogdir ? {
      undef   => $ic_base,
      default => "${ic_base} --xlogdir '${xlogdir}'"
    }

    # The xlogdir need to be present before initdb runs.
    # If xlogdir is default it's created by package installer
    if($xlogdir) {
      $require_before_initdb = [$datadir, $xlogdir]
    } else {
      $require_before_initdb = [$datadir]
    }


    $initdb_command = $locale ? {
      undef   => $ic_xlog,
      default => "${ic_xlog} --locale '${locale}'"
    }

    # This runs the initdb command, we use the existance of the PG_VERSION
    # file to ensure we don't keep running this command.
    exec { 'edbas_initdb':
      command   => $initdb_command,
      creates   => "${datadir}/PG_VERSION",
      user      => $user,
      group     => $group,
      logoutput => on_failure,
      require   => File[$require_before_initdb],
    }
    # The package will take care of this for us the first time, but if we
    # ever need to init a new db we need to copy these files explicitly
  } elsif $encoding != undef {
    # [workaround]
    # by default pg_createcluster encoding derived from locale
    # but it do does not work by installing edbas via puppet because puppet
    # always override LANG to 'C'
    edbas_psql { "Set template1 encoding to ${encoding}":
      command => "UPDATE pg_database
        SET datistemplate = FALSE
        WHERE datname = 'template1'
        ;
        UPDATE pg_database
        SET encoding = pg_char_to_encoding('${encoding}'), datistemplate = TRUE
        WHERE datname = 'template1'",
      unless  => "SELECT datname FROM pg_database WHERE
        datname = 'template1' AND encoding = pg_char_to_encoding('${encoding}')",
    }
  }
  
  if($logdir) {
    # Make sure the log directory exists, and has the correct permissions.
    file { $logdir:
      ensure => directory,
      owner  => $user,
      group  => $group,
      require => Exec['edbas_initdb'],
    }
  }
}
