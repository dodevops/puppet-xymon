# frozen_string_literal: true

require 'spec_helper'

describe 'xymon::client::monitor' do
  let(:title) { 'testmonitor' }
  let(:pre_condition) do
    "
    class {
      'xymon::client':
        repository_url =>'https://repo.company.com',
        gpg_url => 'https://repo.company.com/gpg',
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
          os_facts.merge(
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
          is_expected.to compile.with_all_deps
          is_expected.to contain_sudo__conf('callroot')
          is_expected.to contain_package('sysstat')
          is_expected.to contain_xymon__client__monitor('testmonitor')
          is_expected.to contain_file('/etc/xymon/files/testfile1')
          is_expected.to contain_file('/etc/xymon/files/testfile2')
          is_expected.to contain_file('/etc/xymon/clientlaunch.d/testmonitor.sh')
          is_expected.to contain_file('/etc/xymon/clientlaunch.d/testmonitor.cfg')
        }
      end

      context 'with logrotate' do
        let(:facts) { os_facts.merge(sudoversion: '3.0.0') }
        let(:params) do
          {
            script_source: 'puppet://xymon/testmonitor.sh',
            logrotate: {
              'path' => '/var/log/xymon/testmonitor.log',
              'size' => '10M',
              'rotate' => 5,
            },
          }
        end

        it { is_expected.to compile.with_all_deps }

        it do
          is_expected.to contain_logrotate__rule('testmonitor.monitor').with(
            ensure: 'present',
            path: '/var/log/xymon/testmonitor.log',
            size: '10M',
            rotate: 5,
            compress: true,
          )
        end
      end
    end
  end
end
