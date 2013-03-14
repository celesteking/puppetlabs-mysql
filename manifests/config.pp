# Class: mysql::config
#
# Parameters:
#
#   [*root_password*]     - root user password.
#   [*old_root_password*] - previous root user password,
#   [*bind_address*]      - address to bind service. IP or hostname or "SKIP"
#                           By default, we don't bind to TCP socket.
#   [*port*]              - port to bind service.
#   [*etc_root_password*] - whether to save /etc/my.cnf.
#   [*service_name*]      - mysql service name.
#   [*config_file*]       - my.cnf configuration file path.
#   [*socket*]            - mysql socket.
#   [*datadir*]           - path to datadir.
#   [*ssl]                - enable ssl
#   [*ssl_ca]             - path to ssl-ca
#   [*ssl_cert]           - path to ssl-cert
#   [*ssl_key]            - path to ssl-key
#   [*log_error]          - path to mysql error log
#   [*default_engine]     - configure a default table engine
#   [*root_group]         - use specified group for root-owned files
#   [*restart]            - whether to restart mysqld (true/false)
#
# Actions:
#
# Requires:
#
#   class mysql::server
#
# Usage:
#
#   class { 'mysql::config':
#     root_password => 'changeme',
#     bind_address  => $::ipaddress,
#   }
#
class mysql::config (
  $root_password     = 'UNSET',
  $old_root_password = '',
  $bind_address      = $mysql::params::bind_address,
  $port              = $mysql::params::port,
  $etc_root_password = $mysql::params::etc_root_password,
  $service_name      = undef,
  $config_file       = $mysql::params::config_file,
  $socket            = $mysql::params::socket,
  $pidfile           = $mysql::params::pidfile,
  $datadir           = $mysql::params::datadir,
  $ssl               = $mysql::params::ssl,
  $ssl_ca            = $mysql::params::ssl_ca,
  $ssl_cert          = $mysql::params::ssl_cert,
  $ssl_key           = $mysql::params::ssl_key,
  $log_error         = $mysql::params::log_error,
  $default_engine    = 'UNSET',
  $root_group        = $mysql::params::root_group,
  $restart           = $mysql::params::restart,
  $purge_conf_dir    = false
) inherits mysql::params {

  File {
    owner  => 'root',
    group  => $root_group,
    mode   => '0400',
    notify => $restart ? {
      true    => Exec['mysqld-restart'],
      default => undef,
    },
  }

  $service_name_real = $service_name ? {
    undef   => $mysql::server::service_name ? {
      undef   => $mysql::params::service_name,
      default => $mysql::server::service_name,
    },
    default => $service_name,
  }

  if $ssl and $ssl_ca == undef {
    fail('The ssl_ca parameter is required when ssl is true')
  }

  if $ssl and $ssl_cert == undef {
    fail('The ssl_cert parameter is required when ssl is true')
  }

  if $ssl and $ssl_key == undef {
    fail('The ssl_key parameter is required when ssl is true')
  }

  # This kind of sucks, that I have to specify a difference resource for
  # restart.  the reason is that I need the service to be started before mods
  # to the config file which can cause a refresh
  exec { 'mysqld-restart':
    command     => "service ${service_name_real} restart",
    logoutput   => on_failure,
    refreshonly => true,
    path        => '/sbin/:/usr/sbin/:/usr/bin/:/bin/',
  }

  # manage root password if it is set
  if $root_password != 'UNSET' {
    case $old_root_password {
      ''      : { $old_pw = '' }
      default : { $old_pw = "-p'${old_root_password}'" }
    }

    exec { 'set_mysql_rootpw':
      command   => "mysqladmin -u root ${old_pw} password '${root_password}'",
      logoutput => true,
      unless    => "mysqladmin -u root -p'${root_password}' status > /dev/null",
      path      => '/usr/local/sbin:/usr/bin:/usr/local/bin',
      notify    => $restart ? {
        true  => Exec['mysqld-restart'],
        false => undef,
      },
      require   => File[$conf_dir],
    }

    file { '/root/.my.cnf':
      content => template('mysql/my.cnf.pass.erb'),
      require => Exec['set_mysql_rootpw'],
    }

    if $etc_root_password {
      file { '/etc/my.cnf':
        content => template('mysql/my.cnf.pass.erb'),
        require => Exec['set_mysql_rootpw'],
      }
    }
  } else {
    file { '/root/.my.cnf': ensure => present, }
  }

  file { '/etc/mysql':
    ensure => directory,
    mode   => '0755',
  }

  file { $conf_dir:
    ensure  => directory,
    mode    => '0755',
    recurse => $purge_conf_dir,
    purge   => $purge_conf_dir,
  }

  file { $conf_dir_local:
    ensure => directory,
    mode   => '0755',
  }

  file { $config_file:
    content => template('mysql/my.cnf.erb'),
    mode    => '0644',
  }

  ##
  # Here goes the [mysqld] section, which is split off into separate file
  ##
  $mysqld_params = {
    user                    => mysql,
    'pid-file'              => $pidfile,
    'socket'                => $socket,
    port                    => $port,
    basedir                 => $basedir,
    datadir                 => $datadir,
    tmpdir                  => '/tmp',
    'skip-external-locking' => true,
    'symbolic-links'        => '0',
  }

  if $log_error == 'syslog' {
    $mysqld_params_add1 = {
      'syslog is the logger' => false,
    }
  } else {
    $mysqld_params_add1 = {
      'log_error' => $log_error
    }
  }

  if $ssl {
    $mysqld_params_add2 = {
      'ssl-ca'   => $ssl_ca,
      'ssl-cert' => $ssl_cert,
      'ssl-key'  => $ssl_key,
    }
  } else {
    $mysqld_params_add2 = {
    }
  }

  if $bind_address =~ /^(?i)skip$/ {
    $mysqld_params_add3 = {
      'bind-address'    => false,
      'skip-networking' => true,
    }
  } else {
    $mysqld_params_add3 = {
      'bind-address' => $bind_address,
    }
  }

  if $default_engine == 'UNSET' {
    $mysqld_params_add4 = {
    }
  } else {
    $mysqld_params_add4 = {
      'default-storage-engine' => $default_engine
    }
  }

  mysql::server::config { 'mysqld-general':
    settings => {
      'mysqld' => merge($mysqld_params, $mysqld_params_add1, $mysqld_params_add2, $mysqld_params_add3, $mysqld_params_add4), # Puppet hash handling is pure crap
    }
  }

}
