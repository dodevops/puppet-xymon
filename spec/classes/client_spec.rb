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
          }
        when 'RedHat'
          it {
            is_expected.to contain_class('xymon::repository::yum')
            is_expected.to contain_yumrepo('xymon')
          }
        when 'Suse'
          it {
            is_expected.to contain_class('xymon::repository::zypper')
            is_expected.to contain_zypprepo('xymon')
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

      context 'monitors' do
        let(:facts) do
          os_facts.merge!(
            sudoversion: '3.0.0',
          )
        end
        let(:params) do
          {
            repository_url: 'https://repo.company.com',
            gpg_url: 'https://repo.company.com/gpg',
            gpg_id: '6688A3782BBFE5A4',
            xymon_server: 'xymon.company.com',
            config_file: '/etc/xymon.conf',
            package: 'xymon-client',
            xymon_config_dir: '/etc/xymon',
            clientlaunch_config: '/etc/xymon/clientlaunch.d',
            files_path: '/etc/xymon/files',
            monitors: {
              testmonitor: {
                script_source: 'puppet://xymon/testmonitor.sh',
                arguments: ['--yellow=80', '--red=90'],
                files: {
                  testfile1: {
                      source: 'puppet://xymon/testfile1',
                  },
                  testfile2: {
                      source: 'puppet://xymon/testfile2',
                  },
                },
                packages: {
                  sysstat: {
                    ensure: 'latest',
                  },
                },
                sudo: {
                  callroot: {
                    ensure: 'present',
                    content: 'janedoe ALL=(ALL) NOPASSWD: ALL',
                  },
                },
              },
            },
          }
        end

        it {
          is_expected.to compile
          is_expected.to contain_sudo__conf('callroot')
          is_expected.to contain_package('sysstat')
          is_expected.to contain_file('/etc/xymon/files/testfile1')
          is_expected.to contain_file('/etc/xymon/files/testfile2')
          is_expected.to contain_file('/etc/xymon/clientlaunch.d/testmonitor.sh')
          is_expected.to contain_file('/etc/xymon/clientlaunch.d/testmonitor.cfg')
        }
      end
    end
  end
end
