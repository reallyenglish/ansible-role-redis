require 'spec_helper'

redis_package_name = 'redis'
redis_service_name = 'redis'
redis_config       = '/etc/redis/redis.conf'
redis_user         = 'redis'
redis_group        = 'redis'
redis_dir          = '/var/db/redis'
redis_log_dir      = '/var/log/redis'
redis_port         = 6379
redis_pidfile = '/var/run/redis/redis.pid'
redis_logfile = '/var/log/redis/redis.log'

sentinel_service_name = 'sentinel'
sentinel_port = 26379
sentinel_conf = '/etc/redis/sentinel.conf'
sentinel_user = 'redis'
sentinel_group = 'redis'
sentinel_log_dir = '/var/log/redis'
sentinel_log_file = "#{sentinel_log_dir}/sentinel.log"

case os[:family]
when 'freebsd'
  redis_package_name = 'redis'
  redis_service_name = 'redis'
  redis_config       = '/usr/local/etc/redis/redis.conf'
  sentinel_conf = '/usr/local/etc/redis/sentinel.conf'
end

redis_config_ansible = "#{ redis_config }.ansible"
sentinel_conf_ansible = "#{ sentinel_conf }.ansible"

case os[:family]
when 'freebsd'
  describe file('/etc/rc.conf.d/sentinel') do
    it { should be_file }
    its(:content) { should match Regexp.escape('sentinel_config="/usr/local/etc/redis/sentinel.conf"') }
  end
end

describe file (sentinel_conf) do
  it { should be_file }
  it { should be_owned_by sentinel_user }
  it { should be_grouped_into sentinel_group }
  its(:content) { should match /^include #{ Regexp.escape(sentinel_conf_ansible) }/ }
  its(:content) { should match /^sentinel monitor my_database #{ Regexp.escape('10.0.2.15') } 6379 2/ }
end

describe file(sentinel_conf_ansible) do
  it { should be_file }
  its(:content) { should match /port 26379/ }
  its(:content) { should match /dir \/tmp/ }
  its(:content) { should match /logfile #{ Regexp.escape(sentinel_log_file) }/ }
  its(:content) { should match /sentinel parallel-syncs my_database/ }
  its(:content) { should match /sentinel down-after-milliseconds my_database 5000/ }
  its(:content) { should match /sentinel parallel-syncs my_database 1/ }
  its(:content) { should match /sentinel failover-timeout my_database 180000/ }
end

describe file(sentinel_log_dir) do
  it { should be_directory }
  it { should be_mode 755 }
  it { should be_owned_by sentinel_user }
  it { should be_grouped_into sentinel_group }
end

describe file(sentinel_log_file) do
  it { should be_file }
  it { should be_owned_by sentinel_user }
  it { should be_grouped_into sentinel_group }
end

describe service(sentinel_service_name) do
  it { should be_enabled }
  it { should be_running }
end

describe port(sentinel_port) do
  it { should be_listening }
end

describe file(redis_dir) do
  it { should be_directory }
  it { should be_mode 755 }
  it { should be_owned_by redis_user }
  it { should be_grouped_into redis_group }
end

describe file(redis_config) do
  it { should be_file }
  it { should be_owned_by redis_user }
  it { should be_grouped_into redis_group }
  its(:content) { should match /^include #{ Regexp.escape(redis_config_ansible) }/ }
  # this is the master and should not be a sleave of any
  its(:content) { should_not match /^slaveof / }
end

describe file(redis_config_ansible) do
  it { should be_file }
  its(:content) { should match Regexp.escape("pidfile #{redis_pidfile}") }
  its(:content) { should match Regexp.escape("logfile #{redis_logfile}") }
  its(:content) { should match Regexp.escape("dir #{redis_dir}") }
end

describe service(redis_service_name) do
  it { should be_running }
  it { should be_enabled }
end

describe port(redis_port) do
  it { should be_listening }
end

describe command('redis-cli ping') do
  its(:stdout) { should match /PONG/ }
  its(:stderr) { should eq '' }
  its(:exit_status) { should eq 0 }
end

describe command("redis-cli -p #{sentinel_port} info") do
  its(:stdout) { should match /master0:name=my_database,status=ok,address=10.0.2.15:6379,slaves=0,sentinels=1/ }
  its(:stderr) { should match /^$/ }
end
