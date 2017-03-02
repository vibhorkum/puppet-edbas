# Define for conveniently creating a role, database and assigning the correct
# permissions. See README.md for more details.
define edbas::server::db (
  $user,
  $password,
  $comment    = undef,
  $dbname     = $title,
  $encoding   = $edbas::server::encoding,
  $locale     = $edbas::server::locale,
  $grant      = 'ALL',
  $tablespace = undef,
  $template   = 'template0',
  $istemplate = false,
  $owner      = undef
) {

  if ! defined(edbas::server::database[$dbname]) {
    edbas::server::database { $dbname:
      comment    => $comment,
      encoding   => $encoding,
      tablespace => $tablespace,
      template   => $template,
      locale     => $locale,
      istemplate => $istemplate,
      owner      => $owner,
    }
  }

  if ! defined(edbas::server::role[$user]) {
    edbas::server::role { $user:
      password_hash => $password,
      before        => edbas::server::database[$dbname],
    }
  }

  if ! defined(edbas::server::database_grant["GRANT ${user} - ${grant} - ${dbname}"]) {
    edbas::server::database_grant { "GRANT ${user} - ${grant} - ${dbname}":
      privilege => $grant,
      db        => $dbname,
      role      => $user,
    } -> edbas::Validate_db_connection<| database_name == $dbname |>
  }

  if($tablespace != undef and defined(edbas::server::tablespace[$tablespace])) {
    edbas::server::tablespace[$tablespace]->edbas::server::database[$name]
  }
}
