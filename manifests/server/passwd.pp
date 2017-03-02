# PRIVATE CLASS: do not call directly
class edbas::server::passwd {
  $postgres_password = $edbas::server::postgres_password
  $user              = $edbas::server::user
  $group             = $edbas::server::group
  $psql_path         = $edbas::server::psql_path
  $port              = $edbas::server::port

  if ($postgres_password != undef) {
    # NOTE: this password-setting logic relies on the pg_hba.conf being
    #  configured to allow the postgres system user to connect via psql
    #  without specifying a password ('ident' or 'trust' security). This is
    #  the default for pg_hba.conf.
    $escaped = edbas_escape($postgres_password)
    exec { 'set_postgres_postgrespw':
      # This command works w/no password because we run it as postgres system
      # user
      command     => "${psql_path} -c \"ALTER ROLE \\\"${user}\\\" PASSWORD \${NEWPASSWD_ESCAPED}\"",
      user        => $user,
      group       => $group,
      logoutput   => true,
      cwd         => '/tmp',
      environment => [
        "PGPASSWORD=${postgres_password}",
        "PGPORT=${port}",
        "NEWPASSWD_ESCAPED=${escaped}",
      ],
      # With this command we're passing -h to force TCP authentication, which
      # does require a password.  We specify the password via the PGPASSWORD
      # environment variable. If the password is correct (current), this
      # command will exit with an exit code of 0, which will prevent the main
      # command from running.
      unless      => "${psql_path} -h localhost -p ${port} -c 'select 1' > /dev/null",
      path        => '/usr/bin:/usr/local/bin:/bin',
    }
  }
}
