# Activate an extension on a postgresql database
define edbas::server::extension (
  $database,
  $extension = $name,
  $ensure = 'present',
  $package_name = undef,
  $package_ensure = undef,
  $connect_settings = $edbas::server::default_connect_settings,
) {
  $user          = $edbas::server::user
  $group         = $edbas::server::group
  $psql_path     = $edbas::server::psql_path
  $postgres_password = $edbas::server::postgres_password
  $port              = $edbas::server::port

  case $ensure {
    'present': {
      $command = "CREATE EXTENSION \"${extension}\""
      $unless_comp = '='
      $package_require = []
      $package_before = Edbas_psql["Add ${extension} extension to ${database}"]
    }

    'absent': {
      $command = "DROP EXTENSION \"${extension}\""
      $unless_comp = '!='
      $package_require = Edbas_psql["Add ${extension} extension to ${database}"]
      $package_before = []
    }

    default: {
      fail("Unknown value for ensure '${ensure}'.")
    }
  }


  edbas_psql {"Add ${extension} extension to ${database}":
    psql_user        => $user,
    psql_group       => $group,
    psql_path        => $psql_path,
    connect_settings => $connect_settings,
    db               => $database,
    environment => [
      "PGDATABASE=${database}",
      "PGPASSWORD=${postgres_password}",
      "PGPORT=${port}",
    ],

    command          => $command,
    unless           => "SELECT t.count FROM (SELECT count(extname) FROM pg_extension WHERE extname = '${extension}') as t WHERE t.count ${unless_comp} 1",
    require          => Edbas::Server::Database[$database],
  }

  if $package_name {
    $_package_ensure = $package_ensure ? {
      undef   => $ensure,
      default => $package_ensure,
    }

    ensure_packages($package_name, {
      ensure  => $_package_ensure,
      tag     => 'edbas',
      require => $package_require,
      before  => $package_before,
    })
  }
}
