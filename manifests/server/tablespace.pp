# This module creates tablespace. See README.md for more details.
define edbas::server::tablespace(
  $location,
  $owner   = undef,
  $spcname = $title,
  $connect_settings = $edbas::server::default_connect_settings,
) {
  $user       = $edbas::server::user
  $group      = $edbas::server::group
  $epsql_path = $edbas::server::psql_path
  $db         = $edbas::server::default_database

  # If the connection settings do not contain a port, then use the local server port
  if $connect_settings != undef and has_key( $connect_settings, 'PGPORT') {
    $port = undef
  } else {
    $port = $edbas::server::port
  }

  Edbas_psql { 
    db              => $db,
    psql_user        => $user,
    psql_group       => $group,
    psql_path        => $psql_path,
    port             => $port,
    connect_settings => $connect_settings,
  }

  if ($owner == undef) {
    $owner_section = ''
  } else {
    $owner_section = "OWNER \"${owner}\""
  }

  $create_tablespace_command = "CREATE TABLESPACE \"${spcname}\" ${owner_section} LOCATION '${location}'"

  file { $location:
    ensure  => directory,
    owner   => $user,
    group   => $group,
    mode    => '0700',
    seluser => 'system_u',
    selrole => 'object_r',
    seltype => 'edbas_db_t',
    require => Class['edbas::server'],
  }

  $create_ts = "Create tablespace '${spcname}'"
  edbas_psql { "Create tablespace '${spcname}'":
    command => $create_tablespace_command,
    unless  => "SELECT spcname FROM pg_tablespace WHERE spcname='${spcname}'",
    require => [Class['edbas::server'], File[$location]],
  }

  if($owner != undef and defined(Edbas::Server::Role[$owner])) {
    edbas::server::role[$owner]->Edbas_psql[$create_ts]
  }
}
