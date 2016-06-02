require 'infrataster/rspec'
require 'infrataster-plugin-redis'
require 'redis'

ENV['VAGRANT_CWD'] = File.dirname(__FILE__)
ENV['LANG'] = 'C'

if ENV['JENKINS_HOME']
  # XXX "bundle exec vagrant" fails to load.
  #
  # > bundle exec vagrant --version
  # bundler: failed to load command: vagrant (/usr/local/bin/vagrant)
  # Gem::Exception: can't find executable vagrant
  #   /usr/local/lib/ruby/gems/2.2/gems/bundler-1.12.1/lib/bundler/rubygems_integration.rb:373:in `block in replace_bin_path'
  #   /usr/local/lib/ruby/gems/2.2/gems/bundler-1.12.1/lib/bundler/rubygems_integration.rb:387:in `block in replace_bin_path'
  #   /usr/local/bin/vagrant:23:in `<top (required)>'
  #
  # include the path of bin to vagrant
  vagrant_real_path = `pkg info -l vagrant | grep -v '/usr/local/bin/vagrant' | grep -E 'bin\/vagrant$'| sed -e 's/^[[:space:]]*//'`
  vagrant_bin_dir = File.dirname(vagrant_real_path)
  ENV['PATH'] = "#{vagrant_bin_dir}:#{ENV['PATH']}"
end

Infrataster::Server.define(
  :master,
  '192.168.90.100',
  vagrant: true,
  redis: { host: '192.168.90.100' }
)

Infrataster::Server.define(
  :slave1,
  '192.168.90.201',
  vagrant: true,
  redis: { host: '192.168.90.201' }
)

Infrataster::Server.define(
  :slave2,
  '192.168.90.202',
  vagrant: true,
  redis: { host: '192.168.90.202' }
)

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
