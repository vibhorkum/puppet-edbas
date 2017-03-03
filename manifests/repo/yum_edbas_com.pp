# PRIVATE CLASS: do not use directly
class edbas::repo::yum_edbas_com inherits edbas::repo {
  $version_parts   = split($edbas::repo::version, '[.]')
  $package_version = "${version_parts[0]}${version_parts[1]}"
  $gpg_key_path    = "/etc/pki/rpm-gpg/ENTERPRISEDB-GPG-KEY-${package_version}"

  file { $gpg_key_path:
    source => 'puppet:///modules/edbas/ENTERPRISEDB-GPG-KEY',
    before => Yumrepo['yum.edbas.com']
  }


  yumrepo { 'yum.edbas.com':
    descr    => "edbas ${edbas::repo::version} \$releasever - \$basearch",
    baseurl  => "http://${yumuser}:${yumpassword}@yum.enterprisedb.com/${edbas::repo::version}/redhat/rhel-\$releasever-\$basearch",
    enabled  => 1,
    gpgcheck => 1,
    gpgkey   => "file:///etc/pki/rpm-gpg/ENTERPRISEDB-GPG-KEY-${package_version}"
  }

  yumrepo { 'yum.edbas.tools':
    descr    => "edbas tools ${edbas::repo::version} \$releasever - \$basearch",
    baseurl  => "http://${yumuser}:${yumpassword}@yum.enterprisedb.com/tools/redhat/rhel-\$releasever-\$basearch",
    enabled  => 1,
    gpgcheck => 1,
    gpgkey   => "file:///etc/pki/rpm-gpg/ENTERPRISEDB-GPG-KEY-${package_version}"
  }

  yumrepo { 'yum.edbas.dependencies':
    descr    => "edbas dependencies ${edbas::repo::version} \$releasever - \$basearch",
    baseurl  => "http://${yumuser}:${yumpassword}@yum.enterprisedb.com/dependencies/redhat/rhel-\$releasever-\$basearch",
    enabled  => 1,
    gpgcheck => 1,
    gpgkey   => "file:///etc/pki/rpm-gpg/ENTERPRISEDB-GPG-KEY-${package_version}"
  }
  Yumrepo['yum.edbas.com'] -> Package<|tag == 'edbas'|>
  Yumrepo['yum.edbas.tools'] -> Package<|tag == 'edbas-tools'|>
  Yumrepo['yum.edbas.dependent'] -> Package<|tag == 'edbas-dependent'|>
}
