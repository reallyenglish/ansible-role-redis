require 'spec_helper'

sentinel_service_name = 'sentinel'
sentinel_port = 26379

describe service(sentinel_service_name) do
  it { should be_enabled }
  it { should be_running }
end

case os[:family]
when 'freebsd'
  describe file('/etc/rc.conf.d/sentinel') do
    it { should be_file }
    its(:content) { should match Regexp.escape('sentinel_config="/usr/local/etc/redis/sentinel.conf"') }
  end
end

describe port(sentinel_port) do
  it { should be_listening }
end
