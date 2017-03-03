# Define for creating a database. See README.md for more details.
define edbas::server::database(
  $comment          = undef,
  $dbname           = $title,
  $owner            = $edbas::server::user,
  $tablespace       = undef,
  $template         = 'template0',
  $encoding         = $edbas::server::encoding,
  $locale           = $edbas::server::locale,
  $istemplate       = false,
  $connect_settings = $edbas::server::default_connect_settings,
) {
  $user          = $edbas::server::user
  $group         = $edbas::server::group
  $psql_path     = $edbas::server::psql_path
  $default_db    = $edbas::server::default_database

  # If possible use the version of the remote database, otherwise
  # fallback to our local DB version
  if $connect_settings != undef and has_key( $connect_settings, 'DBVERSION') {
    $version = $connect_settings['DBVERSION']
  } else {
    $version = $edbas::server::_version
  }

  # If the connection settings do not contain a port, then use the local server port
  if $connect_settings != undef and has_key( $connect_settings, 'PGPORT') {
    $port = undef
  } else {
    $port = $edbas::server::port
  }

  # Set the defaults for the Edbas_psql resource
  Edbas_psql { 
    psql_user        => $user,
    psql_group       => $group,
    psql_path        => $psql_path,
    port             => $port,
    connect_settings => $connect_settings,
  }

  # Optionally set the locale switch. Older versions of createdb may not accept
  # --locale, so if the parameter is undefined its safer not to pass it.
    $locale_option = $locale ? {
      undef   => '',
      default => "LC_COLLATE='${locale}' LC_CTYPE='${locale}'",
    }
    $public_revoke_privilege = 'CONNECT'

  $template_option = $template ? {
    undef   => '',
    default => "TEMPLATE=\"${template}\"",
  }

  $encoding_option = $encoding ? {
    undef   => '',
    default => "ENCODING='${encoding}'",
  }

  $tablespace_option = $tablespace ? {
    undef   => '',
    default => "TABLESPACE=\"${tablespace}\"",
  }


  edbas_psql { "Create db '${dbname}'":
    command => "CREATE DATABASE \"${dbname}\" WITH OWNER=\"${owner}\" ${template_option} ${encoding_option} ${locale_option} ${tablespace_option}",
    unless  => "SELECT datname FROM pg_database WHERE datname='${dbname}'",
    db      => $default_db,
    require => Class['edbas::server::service']
  }~>

  # This will prevent users from connecting to the database unless they've been
  #  granted privileges.
  edbas_psql {"REVOKE ${public_revoke_privilege} ON DATABASE \"${dbname}\" FROM public":
    db          => $default_db,
    refreshonly => true,
  }

 Edbas_psql[ "Create db '${dbname}'" ]->
  edbas_psql {"UPDATE pg_database SET datistemplate = ${istemplate} WHERE datname = '${dbname}'":
    unless => "SELECT datname FROM pg_database WHERE datname = '${dbname}' AND datistemplate = ${istemplate}",
    db     => $default_db,
  }

  if $comment {
    # The shobj_description function was only introduced with 8.2
    $comment_information_function = 'shobj_description'

    Edbas_psql[ "Create db '${dbname}'" ]->
    edbas_psql {"COMMENT ON DATABASE \"${dbname}\" IS '${comment}'":
      unless => "SELECT pg_catalog.${comment_information_function}(d.oid, 'pg_database') as \"Description\" FROM pg_catalog.pg_database d WHERE datname = '${dbname}' AND pg_catalog.${comment_information_function}(d.oid, 'pg_database') = '${comment}'",
      db     => $dbname,
    }
  }

  # Build up dependencies on tablespace
  if($tablespace != undef and defined(Edbas::Server::Tablespace[$tablespace])) {
    Edbas::Server::Tablespace[$tablespace]->Edbas_psql[ "Create db '${dbname}'" ]
  }
}
