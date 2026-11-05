# frozen_string_literal: true

require 'spec_helper'

# Check basic feature

describe 'After xymon::client' do
  let(:hostname) { `/opt/puppetlabs/bin/facter fqdn`.rstrip }

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
      is_expected.to include('XYMONSERVERS="127.0.0.1"')
      is_expected.to match(%r{CLIENTHOSTNAME="#{hostname}"})
    end
  end
end
