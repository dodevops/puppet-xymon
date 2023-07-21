require 'spec_helper'

# Check basic feature

describe 'With configured monitors' do
  describe 'test monitor 1' do
    describe file('/etc/xymon/clientlaunch.d/test.cfg') do
      it {
        is_expected.to exist
      }
      its(:content) do
        is_expected.to match(%r{INTERVAL 5m})
      end
    end
  end

  describe 'test monitor 2' do
    describe file('/etc/xymon/clientlaunch.d/test2.cfg') do
      it {
        is_expected.to exist
      }
      its(:content) do
        is_expected.to match(%r{INTERVAL 10m})
      end
    end
  end

  describe 'test monitor 3' do
    describe file('/etc/xymon/clientlaunch.d/test2.cfg') do
      it {
        is_expected.to exist
      }
      its(:content) do
        is_expected.to.not match(%r{INTERVAL 10m})
        is_expected.to match(%r{CRONDATE 0 0 * * *})
      end
    end
  end
end
