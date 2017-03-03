# puppet-edbas
puppet-code for EDB Advanced Server

This is an initial version of puppet code for ppas-9.5 based on puppet code of postgresql. 
https://github.com/puppetlabs/puppetlabs-postgresql

Symatics and module works similar to postgresql modules.

## Usage and Examples are given below:

### Installation of EDB AS 9.5:

```
class {'edbas::globals':
  manage_package_repo => true,
  version             => '9.5',
  yum_user            => '<yum user>',
  yum_password        => '<yum password>',
 } ->
    class {'edbas::server': }
```

If user wants to apply modify the listen_addresses and port parameters and wants to setup intial pg_hba rule of EDB AS with installation, then they can use following syntax:
```
 class {'edbas::globals':
  manage_package_repo => true,
  version             => '9.5',
  yum_user            => '<yum user>',
  yum_password        => '<yum password>',
 } ->
  class {'edbas::server':
  ip_mask_deny_postgres_user => '0.0.0.0/32',
  ip_mask_allow_all_users    => '0.0.0.0/0',
  listen_addresses           => '*',
  ipv4acls                   => ['host all vibhor 192.168.0.0/24 md5'],
  }
```

### Creating a database with owner in EDBAS 9.5:
For creating database with owner in EDBAS 9.5, following syntax can be used:
```
  edbas::server::db { 'commerce':
  user     => 'commerce',
  password => edbas_password('commerce', 'edb'),
  } 
  
  ```
 
### Creating database and changing owner
```
  edbas::server::database { 'commerce2':
  owner     => 'commerce',
  }
```
If user wants to use sepcific template, following syntax can be used:
```
  edbas::server::database { 'commerce2':
  owner     => 'commerce',
  template  => 'template1',
  }
```

### Creating a tablespace in EDBAS 9.5:
  Following syntax can be used:
  ```
  
 edbas::server::tablespace { 'test_tablespace':
              location => '/tmp/test',
              owner => 'enterprisedb',
 }
 ```
 
### Changing parameter in postgresql.conf:
```
edbas::server::config_entry { 'check_function_bodies':
  value => 'off',
}
```

### For applying new rules in pg_hba.conf:
```
edbas::server::pg_hba_rule { 'allow application using localhost':
  description        => "Open up EDBAS for access from 127.0.0.1/32",
  type               => 'host',
  database           => 'app',
  user               => 'app',
  address            => '127.0.0.1/32',
  auth_method        => 'md5',
  edbas_version => '9.5',
}
```
