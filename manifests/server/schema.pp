# Usage:
# edbas::server::schema {'schemaname':
#     db => 'template1',
# }
#
define edbas::server::schema(
  $db = $edbas::server::default_database,
  $owner  = undef,
  $schema = $title,
  $connect_settings = $edbas::server::default_connect_settings,
) {
  $user      = $edbas::server::user
  $group     = $edbas::server::group
  $psql_path = $edbas::server::psql_path
  $version   = $edbas::server::_version

  # If the connection settings do not contain a port, then use the local server port
  if $connect_settings != undef and has_key( $connect_settings, 'PGPORT') {
    $port = undef
  } else {
    $port = $edbas::server::port
  }

  Edbas_psql {
    db         => $db,
    psql_user  => $user,
    psql_group => $group,
    psql_path  => $psql_path,
    port       => $port,
    connect_settings => $connect_settings,
  }

  $schema_title   = "Create Schema '${title}'"
  $authorization = $owner? {
    undef   => '',
    default => "AUTHORIZATION \"${owner}\"",
  }

  $schema_command = "CREATE SCHEMA \"${schema}\" ${authorization}"
  $unless         = "SELECT nspname FROM pg_namespace WHERE nspname='${schema}' and nspparent=0"

  edbas_psql { $schema_title:
    command => $schema_command,
    unless  => $unless,
    require => Class['Edbas::Server'],
  }

  if($owner != undef and defined(edbas::server::role[$owner])) {
    edbas::server::role[$owner]->edbas_psql[$schema_title]
  }
}
