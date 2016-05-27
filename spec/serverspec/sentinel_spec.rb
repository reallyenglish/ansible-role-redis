require 'spec_helper'

sentinel_service_name = 'sentinel'
sentinel_port = 26379

describe service(sentinel_service_name) do
  it { should be_enabled }
  it { should be_running }
end

describe port(sentinel_port) do
  it { should be_listening }
end
