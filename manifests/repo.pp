# PRIVATE CLASS: do not use directly
class edbas::repo (
  $version = undef,
  $proxy = undef,
  $yumuser = undef,
  $yumpassword = undef
) {
  case $::osfamily {
    'RedHat', 'Linux': {
      if $version == undef {
        fail("The parameter 'version' for 'edbas::repo' is undefined. You must always define it when osfamily == Redhat or Linux")
      }
      class { 'edbas::repo::yum_edbas_com': }
    }

    default: {
      fail("Unsupported managed repository for osfamily: ${::osfamily}, operatingsystem: ${::operatingsystem}, module ${module_name} currently only supports managing repos for osfamily RedHat and Debian")
    }
  }
}
