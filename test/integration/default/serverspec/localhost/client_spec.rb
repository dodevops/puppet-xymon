require 'spec_helper'

hostname = `/opt/puppetlabs/bin/facter fqdn`.rstrip

# Check basic feature

describe 'After xymon::client' do
  describe file('/etc/xymon') do
    it {
      is_expected.to exist
      is_expected.to be_directory
    }
  end

  describe package('xymon-client') do
    it {
      is_expected.to be_installed
    }
  end

  describe file('/etc/xymon/config') do
    it {
      is_expected.to exist
    }
    its(:content) do
      is_expected.to match(%r{XYMONSERVERS="127\.0\.0\.1"})
      is_expected.to match(%r{CLIENTHOSTNAME="#{hostname}"})
    end
  end
end
