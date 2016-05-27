require 'infrataster/rspec'
require 'infrataster-plugin-redis'

ENV['VAGRANT_CWD'] = File.dirname(__FILE__)
ENV['LANG'] = 'C'

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
