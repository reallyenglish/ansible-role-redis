require 'spec_helper'
require 'serverspec'

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

case os[:family]
when 'freebsd'
  redis_package_name = 'redis'
  redis_service_name = 'redis'
  redis_config       = '/usr/local/etc/redis/redis.conf'
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

describe file(redis_log_dir) do
  it { should be_directory }
  it { should be_mode 755 }
  it { should be_owned_by redis_user }
  it { should be_grouped_into redis_group }
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
  its(:content) { should match Regexp.escape("logfile #{redis_logfile}") }
  its(:content) { should match Regexp.escape("dir #{redis_dir}") }
  its(:content) { should match /tcp-backlog 512/ }
end

describe service(redis_service_name) do
  it { should be_running }
  it { should be_enabled }
end

describe port(redis_port) do
  it { should be_listening }
end

describe command ('redis-cli ping') do
  its(:stdout) { should match /PONG/ }
  its(:stderr) { should eq '' }
  its(:exit_status) { should eq 0 }
end
#
#describe file("#{rsyslog_config_dir}/200_client.cfg") do
#  regex_to_test = [
#    '$ActionQueueType LinkedList',
#    '$ActionQueueFileName localhost:5140-queue',
#    '$ActionResumeRetryCount -1',
#    '$ActionQueueSaveOnShutdown on',
#    '*.* @@localhost:5140;RSYSLOG_ForwardFormat'
#  ]
#  it { should be_file }
#  regex_to_test.each do |r|
#    its(:content) { should match Regexp.escape(r) }
#  end
#end
#
#describe file('/tmp/dummy.log') do
#  it { should be_file }
#end
#
## input(
##   type="imfile"
##   File="/tmp/dummy.log"
##   Tag="dummy"
##   Facility="local1"
## )
#
#describe file("#{ rsyslog_config_dir }/900_dummy.log.cfg") do
#  it { should be_file }
#  its(:content) { should match Regexp.escape('File="/tmp/dummy.log"') }
#  its(:content) { should match /Tag="dummy"/ }
#  its(:content) { should match /Facility="local1"/ }
#end
