require 'spec_helper'

describe 'xymon::client' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      context 'default' do
        let(:facts) { os_facts }

        let(:params) do
          {
            repository_url: 'https://repo.company.com',
            gpg_url: 'https://repo.company.com/gpg',
            gpg_id: '6688A3782BBFE5A4',
            xymon_server: 'xymon.company.com',
            config_file: '/etc/xymon.conf',
            package: 'xymon-client',
          }
        end

        case os_facts[:os]['family']
        when 'Debian'
          it {
            is_expected.to contain_class('xymon::repository::apt')
            is_expected.to contain_apt__source('xymon')
            is_expected.to contain_apt__key('6688A3782BBFE5A4')
            is_expected.not_to contain_file_line('include_clientlaunch_d')
          }
        when 'RedHat'
          it {
            is_expected.to contain_class('xymon::repository::yum')
            is_expected.to contain_yumrepo('xymon')
            is_expected.not_to contain_file_line('include_clientlaunch_d')
          }
        when 'Suse'
          it {
            is_expected.to contain_class('xymon::repository::zypper')
            is_expected.to contain_zypprepo('xymon')
            is_expected.to contain_file_line('include_clientlaunch_d')
          }
        else
          raise("Invalid os family #{os_facts[:os]['family']}")
        end

        it {
          is_expected.to compile
          is_expected.to contain_package('xymon-client')
          is_expected.to contain_file('/etc/xymon.conf')
          is_expected.to contain_service('xymon-client')
        }
      end
      context 'ensure present' do
        let(:facts) { os_facts }

        let(:params) do
          {
            repository_url: 'https://repo.company.com',
            gpg_url: 'https://repo.company.com/gpg',
            gpg_id: '6688A3782BBFE5A4',
            xymon_server: 'xymon.company.com',
            config_file: '/etc/xymon.conf',
            package: 'xymon-client',
            package_ensure: 'present',
          }
        end

        it {
          is_expected.to contain_package('xymon-client').with_ensure('present')
        }
      end
    end
  end
end
