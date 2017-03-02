# Install client cli tool. See README.md for more details.
class edbas::client (
  $file_ensure    = 'file',
  $validcon_script_path  = $edbas::params::validcon_script_path,
  $package_name   = $edbas::params::client_package_name,
  $package_ensure = 'present'
) inherits edbas::params {
  validate_absolute_path($validcon_script_path)
  validate_string($package_name)

  package { 'edbas-client':
    ensure => $package_ensure,
    name   => $package_name,
    tag    => 'edbas',
  }

  file { $validcon_script_path:
    ensure => $file_ensure,
    source => 'puppet:///modules/edbas/validate_edbas_connection.sh',
    owner  => 0,
    group  => 0,
    mode   => '0755',
  }

}
