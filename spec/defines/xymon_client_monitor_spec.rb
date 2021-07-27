require 'spec_helper'

describe 'xymon::client::monitor' do
  let(:title) { 'testmonitor' }
  let(:pre_condition) do
    "
    class {
      'xymon::client':
        repository_url =>'https://repo.company.com',
        gpg_url => 'https://repo.company.com/gpg',
        gpg_id => '6688A3782BBFE5A4',
        xymon_server => 'xymon.company.com',
        config_file => '/etc/xymon.conf',
        package => 'xymon-client',
    }
    "
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      context 'default' do
        let(:facts) do
          os_facts.merge!(
            sudoversion: '3.0.0',
          )
        end
        let(:params) do
          {
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
          }
        end

        it {
          is_expected.to compile
          is_expected.to contain_sudo__conf('callroot')
          is_expected.to contain_package('sysstat')
          is_expected.to contain_xymon__client__monitor('testmonitor')
          is_expected.to contain_file('/etc/xymon/files/testfile1')
          is_expected.to contain_file('/etc/xymon/files/testfile2')
          is_expected.to contain_file('/etc/xymon/clientlaunch.d/testmonitor.sh')
          is_expected.to contain_file('/etc/xymon/clientlaunch.d/testmonitor.cfg')
        }
      end
    end
  end
end
