# Manage a database grant. See README.md for more details.
define edbas::server::database_grant(
  $privilege,
  $db,
  $role,
  $psql_db          = undef,
  $psql_user        = undef,
  $connect_settings = undef,
) {
  edbas::server::grant { "database:${name}":
    role             => $role,
    db               => $db,
    privilege        => $privilege,
    object_type      => 'DATABASE',
    object_name      => $db,
    psql_db          => $psql_db,
    psql_user        => $psql_user,
    connect_settings => $connect_settings,
  }
}
