require 'spec_helper'

describe 'mysql::server::config', :type => :define do
  filename = '/etc/mysql/conf.d/test_config.cnf'
	let(:disclaimer) { sprintf("%s\n%s\n\n", "# ***   This file is managed by Puppet    ***", "# *** Automatically generated, don't edit ***")	}
		
  let :facts do
    { :osfamily => 'Debian'}
  end

  let(:title) { File.basename(filename, '.cnf') }

  let(:params) {
    { 'settings' => {
        'mysqld' => {
          'bind-address' => '0.0.0.0'
        }
      }
    }
  }

  it 'should notify the mysql daemon' do
    should contain_file(filename).with_notify('Exec[mysqld-restart]')
  end

  it 'should contain config parameter in content' do
    should contain_file(filename).with_content("#{disclaimer}[mysqld]\nbind-address = 0.0.0.0\n\n")
  end

  it 'should not notify the mysql daemon' do
    params.merge!({ 'notify_service' => false })
    should contain_file(filename).without_notify
  end

  # Note, we don't require on package because it's possible that user doesn't want package management
  it 'should require on $mysql::config::config_file' do
    should contain_file(filename).with_require("File[/etc/mysql/my.cnf]")
  end
end
