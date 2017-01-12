require 'spec_helper'
require 'serverspec'

redis_package_name = 'redis-server'
redis_service_name = 'redis-server'
redis_config       = '/etc/redis/redis.conf'
redis_user         = 'redis'
redis_group        = 'redis'
redis_dir          = "/var/lib/redis"
redis_log_dir      = '/var/log/redis'
redis_port         = 6379
redis_pidfile = '/var/run/redis/redis-server.pid'
redis_logfile = '/var/log/redis/redis-server.log'
redis_password = 'password'

case os[:family]
when 'freebsd'
  redis_package_name = 'redis'
  redis_service_name = 'redis'
  redis_service_name = 'redis'
  redis_config       = '/usr/local/etc/redis/redis.conf'
  redis_dir          = '/var/db/redis'
  redis_pidfile = '/var/run/redis/redis.pid'
  redis_logfile = '/var/log/redis/redis.log'
when "redhat"
  redis_package_name = "redis"
  redis_service_name = "redis"
  redis_config       = "/etc/redis.conf"
  redis_pidfile      = '/var/run/redis/redis.pid'
  redis_logfile      = '/var/log/redis/redis.log'
when "openbsd"
  redis_package_name = "redis"
  redis_service_name = "redis"
  redis_user         = "_redis"
  redis_group        = "_redis"
  redis_pidfile      = "/var/run/redis/redis.pid"
  redis_dir          = "/var/redis"
  redis_logfile      = nil
  redis_log_dir      = nil
end

redis_config_ansible = "#{ redis_config }.ansible"

describe package(redis_package_name) do
  it { should be_installed }
end 

case os[:family]
when 'freebsd'
  describe file('/etc/rc.conf.d/redis') do
    it { should be_file }
    its(:content) { should match Regexp.escape('redis_config="/usr/local/etc/redis/redis.conf"') }
  end
end

if redis_log_dir
  describe file(redis_log_dir) do
    it { should be_directory }
    it { should be_mode 755 }
    it { should be_owned_by redis_user }
    it { should be_grouped_into redis_group }
  end
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
  its(:content) { should_not match /^slaveof / }
end

describe file(redis_config_ansible) do
  it { should be_file }
  its(:content) { should match Regexp.escape("pidfile #{redis_pidfile}") }
  if redis_logfile
    its(:content) { should match Regexp.escape("logfile #{redis_logfile}") }
  end
  its(:content) { should match Regexp.escape("dir #{redis_dir}") }
  its(:content) { should match(/^port 6379/) } # default
  its(:content) { should match(/^databases 17$/) } # non-default
end

if redis_logfile
  describe file(redis_logfile) do
    it { should be_file }
    it { should be_owned_by redis_user }
    it { should be_grouped_into redis_user }
  end
end

describe service(redis_service_name) do
  it { should be_running }
  it { should be_enabled }
end

describe port(redis_port) do
  it { should be_listening }
end

describe command ("redis-cli -a #{redis_password} ping") do
  its(:stdout) { should match /PONG/ }
  its(:stderr) { should eq '' }
  its(:exit_status) { should eq 0 }
end
