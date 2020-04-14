require 'spec_helper'

# Check basic feature

describe 'With configured monitors' do
  describe 'test monitor it' do
    describe file('/etc/xymon/clientlaunch.d/test.cfg') do
      it {
        is_expected.to exist
      }
      its(:content) do
        is_expected.to match(%r{/etc/xymon/clientlaunch\.d/test\.sh})
      end
    end
    describe file('/etc/xymon/clientlaunch.d/test.sh') do
      it {
        is_expected.to exist
      }
      its(:content) do
        is_expected.to match(%r{echo "Just a test"})
      end
    end
    describe package('mc') do
      it {
        is_expected.to be_installed
      }
    end
    describe file('/etc/xymon/files/testfile1') do
      it {
        is_expected.to exist
      }
      its(:content) do
        is_expected.to match(%r{# Just a test})
      end
    end
    describe file('/etc/sudoers.d/testsudo') {
      it {
        is_expected.to exist
      }
      its(:content) do
        is_expected.to match(%r{xymon ALL=(ALL) NOPASSWD: /usr/bin/rootcheck})
      end
    }
    describe package('mc') {
      it {
        is_expected.to be_installed
      }
    }
  end

  describe 'test monitor 2' do
    describe file('/etc/xymon/clientlaunch.d/test2.cfg') do
      it {
        is_expected.to exist
      }
      its(:content) do
        is_expected.to match(%r{/etc/xymon/clientlaunch\.d/test2\.sh})
      end
    end
    describe file('/etc/xymon/clientlaunch.d/test2.sh') do
      it {
        is_expected.to exist
      }
      its(:content) do
        is_expected.to match(%r{echo "Just a second test"})
      end
    end
    describe package('mc') do
      it {
        is_expected.to be_installed
      }
    end
    describe file('/etc/xymon/files/testfile2') do
      it {
        is_expected.to exist
      }
      its(:content) do
        is_expected.to match(%r{# Just a second test})
      end
    end
    describe file('/etc/sudoers.d/testsudo2') {
      it {
        is_expected.to exist
      }
      its(:content) do
        is_expected.to match(%r{xymon ALL=(ALL) NOPASSWD: /usr/bin/rootcheck2})
      end
    }
    describe package('sysstat') {
      it {
        is_expected.to be_installed
      }
    }
  end
end
