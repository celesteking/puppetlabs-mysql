# Class: mysql::params
#
#   The mysql configuration settings.
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class mysql::params {

  $bind_address        = 'skip'
  $port                = 3306
  $etc_root_password   = false
  $ssl                 = false
  $restart             = true

  case $::operatingsystem {
    'Ubuntu': {
      $service_provider = upstart
    }
    default: {
      $service_provider = undef
    }
  }

  case $::osfamily {
    'RedHat': {
      $basedir               = '/usr'
      $datadir               = '/var/lib/mysql'
      $service_name          = 'mysqld'
      $client_package_name   = 'mysql'
      $server_package_name   = 'mysql-server'
      $socket                = '/var/lib/mysql/mysql.sock'
      $pidfile               = '/var/run/mysqld/mysqld.pid'
      $config_file           = '/etc/my.cnf'
      $log_error             = '/var/log/mysqld.log'
      $ruby_package_name     = 'ruby-mysql'
      $ruby_package_provider = 'gem'
      $python_package_name   = 'MySQL-python'
      $php_package_name      = 'php-mysql'
      $java_package_name     = 'mysql-connector-java'
      $root_group            = 'root'
      $ssl_ca                = '/etc/mysql/cacert.pem'
      $ssl_cert              = '/etc/mysql/server-cert.pem'
      $ssl_key               = '/etc/mysql/server-key.pem'
    }

    'Suse': {
      $basedir               = '/usr'
      $datadir               = '/var/lib/mysql'
      $service_name          = 'mysql'
      $client_package_name   = $::operatingsystem ? {
        /OpenSuSE/           => 'mysql-community-server-client',
        /(SLES|SLED)/        => 'mysql-client',
        }
      $server_package_name   = $::operatingsystem ? {
        /OpenSuSE/           => 'mysql-community-server',
        /(SLES|SLED)/        => 'mysql',
        }
      $socket                = $::operatingsystem ? {
        /OpenSuSE/           => '/var/run/mysql/mysql.sock',
        /(SLES|SLED)/        => '/var/lib/mysql/mysql.sock',
        }
      $pidfile               = '/var/run/mysql/mysqld.pid'
      $config_file           = '/etc/my.cnf'
      $log_error             = $::operatingsystem ? {
        /OpenSuSE/           => '/var/log/mysql/mysqld.log',
        /(SLES|SLED)/        => '/var/log/mysqld.log',
        }
      $ruby_package_name     = $::operatingsystem ? {
        /OpenSuSE/           => 'rubygem-mysql',
        /(SLES|SLED)/        => 'ruby-mysql',
        }
      $python_package_name   = 'python-mysql'
      $java_package_name     = 'mysql-connector-java'
      $root_group            = 'root'
      $ssl_ca                = '/etc/mysql/cacert.pem'
      $ssl_cert              = '/etc/mysql/server-cert.pem'
      $ssl_key               = '/etc/mysql/server-key.pem'
    }

    'Debian': {
      $basedir              = '/usr'
      $datadir              = '/var/lib/mysql'
      $service_name         = 'mysql'
      $client_package_name  = 'mysql-client'
      $server_package_name  = 'mysql-server'
      $socket               = '/var/run/mysqld/mysqld.sock'
      $pidfile              = '/var/run/mysqld/mysqld.pid'
      $config_file          = '/etc/mysql/my.cnf'
      $log_error            = '/var/log/mysql/error.log'
      $ruby_package_name    = 'libmysql-ruby'
      $python_package_name  = 'python-mysqldb'
      $php_package_name     = 'php5-mysql'
      $java_package_name    = 'libmysql-java'
      $root_group           = 'root'
      $ssl_ca               = '/etc/mysql/cacert.pem'
      $ssl_cert             = '/etc/mysql/server-cert.pem'
      $ssl_key              = '/etc/mysql/server-key.pem'
    }

    'FreeBSD': {
      $basedir               = '/usr/local'
      $datadir               = '/var/db/mysql'
      $service_name          = 'mysql-server'
      $client_package_name   = 'databases/mysql55-client'
      $server_package_name   = 'databases/mysql55-server'
      $socket                = '/tmp/mysql.sock'
      $pidfile               = '/var/db/mysql/mysql.pid'
      $config_file           = '/var/db/mysql/my.cnf'
      $log_error             = "/var/db/mysql/${::hostname}.err"
      $ruby_package_name     = 'ruby-mysql'
      $ruby_package_provider = 'gem'
      $python_package_name   = 'databases/py-MySQLdb'
      $php_package_name      = 'php5-mysql'
      $java_package_name     = 'databases/mysql-connector-java'
      $root_group            = 'wheel'
      $ssl_ca                = undef
      $ssl_cert              = undef
      $ssl_key               = undef
    }

    default: {
      case $::operatingsystem {
        'Amazon': {
          $basedir               = '/usr'
          $datadir               = '/var/lib/mysql'
          $service_name          = 'mysqld'
          $client_package_name   = 'mysql'
          $server_package_name   = 'mysql-server'
          $socket                = '/var/lib/mysql/mysql.sock'
          $config_file           = '/etc/my.cnf'
          $log_error             = '/var/log/mysqld.log'
          $ruby_package_name     = 'ruby-mysql'
          $ruby_package_provider = 'gem'
          $python_package_name   = 'MySQL-python'
          $php_package_name      = 'php-mysql'
          $java_package_name     = 'mysql-connector-java'
          $root_group            = 'root'
          $ssl_ca                = '/etc/mysql/cacert.pem'
          $ssl_cert              = '/etc/mysql/server-cert.pem'
          $ssl_key               = '/etc/mysql/server-key.pem'
        }

        default: {
          fail("Unsupported osfamily: ${::osfamily} operatingsystem: ${::operatingsystem}, module ${module_name} only support osfamily RedHat, Debian, and FreeBSD, or operatingsystem Amazon")
        }
      }
    }
  }

  $conf_dir       = '/etc/mysql/conf.d'
  $conf_dir_local = '/etc/mysql/conf.local.d'

  $disclaimer = sprintf("%s\n%s\n", "# ***   This file is managed by Puppet    ***", "# *** Automatically generated, don't edit ***")

}
