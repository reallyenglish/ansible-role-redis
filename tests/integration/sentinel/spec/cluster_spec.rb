require "spec_helper"

# if the build is in jenkins, sleep longer
if ENV["JENKINS_HOME"]
  sleep 20
else
  sleep 10
end

master_name = "testdb"
slaves = [server(:slave1), server(:slave2)]
password = "password"

[server(:master), server(:slave1), server(:slave2)].each do |s|
  describe s do
    let(:redis) do
      Redis.new(
        host: s.server.address,
        port: 6379,
        password: password
      )
    end
    it "should return PONG" do
      r = redis.ping
      expect(r).to eq("PONG")
    end
  end
end

describe server(:master) do
  let(:redis) do
    Redis.new(
      host: server(:master).server.address,
      port: 26_379
    )
  end
  let(:sentinel_master_result) do
    redis.sentinel("master", master_name)
  end
  let(:sentinel_slaves_result) do
    redis.sentinel("slaves", master_name)
  end
  let(:sentinel_get_master_result) do
    redis.sentinel("get-master-addr-by-name", master_name)
  end

  it "should be connected to 2 sentinels" do
    expect(sentinel_master_result["num-other-sentinels"]).to eq("2")
  end
  it "should be the master state" do
    expect(sentinel_master_result["flags"]).to eq("master")
  end
  it "should connected to two slaves" do
    expect(sentinel_master_result["num-slaves"]).to eq("2")
  end

  it "should returns two slaves" do
    expect(sentinel_slaves_result.length).to eq(2)
  end

  it "should report the slaves think they are a slave" do
    sentinel_slaves_result.each do |s|
      expect(s["role-reported"]).to eq("slave")
      expect(s["flags"]).to eq("slave")
    end
  end

  it "should report the correct master at the moment" do
    expect(sentinel_get_master_result).to eq(["192.168.90.100", "6379"])
  end
end

slaves.each do |s|
  describe s do
    let(:redis) do
      Redis.new(
        host: s.server.address,
        port: 26_379
      )
    end
    let(:sentinel_masters_result) do
      redis.sentinel("master", master_name)
    end
    it "should report the correct master" do
      expect(sentinel_masters_result["ip"]).to eq("192.168.90.100")
    end

    it "should report num-slaves is two" do
      expect(sentinel_masters_result["num-slaves"].to_i).to eq(2)
    end
  end
end

context "when client has sentinel support" do
  describe "cluster" do
    let(:url) do
      "redis://#{master_name}"
    end
    let(:sentinels) do
      [
        { host: server(:master).server.address, port: 26_379 },
        { host: server(:slave1).server.address, port: 26_379 },
        { host: server(:slave2).server.address, port: 26_379 }
      ]
    end
    let(:redis_master) do
      Redis.new(
        url: url,
        sentinels: sentinels,
        password: password,
        role: :master
      )
    end
    let(:redis_slave) do
      Redis.new(
        url: url,
        sentinels: sentinels,
        password: password,
        role: :master
      )
    end
    describe "master" do
      it "should accept set request" do
        r = redis_master.set("foo", "bar")
        expect(r).to eq("OK")
      end
    end

    describe "slaves" do
      it "should return bar" do
        r = redis_slave.get("foo")
        expect(r).to eq("bar")
      end
    end
  end
end

context "when master redis is down" do
  describe server(:master) do
    let(:redis) do
      Redis.new(
        host: server(:master).server.address,
        port: 26_379
      )
    end
    let(:sentinel_get_master_result) do
      redis.sentinel("get-master-addr-by-name", master_name)
    end
    before(:all) do
      server(:master).server.ssh_exec "sudo service redis stop"
      sleep 10
    end
    it "should report current master is not server(:master)" do
      expect(sentinel_get_master_result).not_to eq([server(:master).server.address, "6379"])
    end
  end

  slaves.each do |s|
    describe s do
      let(:redis) do
        Redis.new(
          host: s.server.address,
          port: 26_379
        )
      end
      let(:sentinel_masters_result) do
        redis.sentinel("master", master_name)
      end
      it "should report the previous master is not a master" do
        expect(sentinel_masters_result["ip"]).not_to eq(server(:master).server.address)
      end
    end
  end
  describe "cluster" do
    let(:url) do
      "redis://#{master_name}"
    end
    let(:sentinels) do
      [
        { host: server(:master).server.address, port: 26_379 },
        { host: server(:slave1).server.address, port: 26_379 },
        { host: server(:slave2).server.address, port: 26_379 }
      ]
    end
    let(:redis_master) do
      Redis.new(
        url: url,
        sentinels: sentinels,
        password: password,
        role: :master
      )
    end
    let(:redis_slave) do
      Redis.new(
        url: url,
        sentinels: sentinels,
        password: password,
        role: :master
      )
    end
    describe "master" do
      it "should accept set request" do
        r = redis_master.set("foo", "buz")
        expect(r).to eq("OK")
      end
    end

    describe "slaves" do
      it "should return buz" do
        r = redis_slave.get("foo")
        expect(r).to eq("buz")
      end
    end
  end
end

context "when the original master is back" do
  describe server(:master) do
    before(:all) do
      server(:master).server.ssh_exec "sudo service redis start"
      sleep 15
    end
    let(:redis) do
      Redis.new(
        host: server(:master).server.address,
        password: password,
        port: 6379
      )
    end
    let(:sentinel) do
      Redis.new(
        host: server(:master).server.address,
        port: 26_379
      )
    end
    let(:sentinel_get_master_result) do
      sentinel.sentinel("get-master-addr-by-name", master_name)
    end
    let(:redis_info_result) do
      redis.info
    end

    it "should report it is a slave" do
      expect(redis_info_result["role"]).to eq("slave")
      expect(redis_info_result["master_host"]).not_to eq(server(:master).server.address)
      expect(sentinel_get_master_result).not_to eq([server(:master).server.address, "6379"])
    end

    it "should return buz that has been set while it was down" do
      r = redis.get("foo")
      expect(r).to eq("buz")
    end
  end
end

context "when server(:master) is promoted to master" do
  slaves.each do |s|
    describe s do
      let(:sentinel) do
        Redis.new(
          host: s.server.address,
          port: 26_379
        )
      end
      before :each do
        # "debug sleep 10" makes the server a slave by pausing. thus,
        # server(:master) becomes the master.
        # as redis gem does not support debug, use redis-cli.
        current_server.ssh_exec "redis-cli -a #{password} debug sleep 10"
      end
      it "should report it is a slave" do
        r = sentinel.sentinel("get-master-addr-by-name", master_name)
        expect(r).not_to eq([s.server.address, "6379"])
      end
    end
  end

  describe server(:master) do
    let(:redis) do
      Redis.new(
        host: server(:master).server.address,
        port: 6379,
        password: password
      )
    end
    let(:redis_info_result) do
      redis.info
    end
    it "should report it is the master" do
      sleep 30
      expect(redis_info_result["role"]).to eq("master")
      expect(redis_info_result["master_host"]).not_to eq(server(:master).server.address)
    end
  end
end

context "when master and slave1 are down" do
  describe server(:slave2) do
    let(:redis) do
      Redis.new(
        host: server(:slave2).server.address,
        port: 6379,
        password: password
      )
    end
    let(:sentinel) do
      Redis.new(
        host: server(:slave2).server.address,
        port: 26_379
      )
    end
    let(:sentinel_get_master_result) do
      sentinel.sentinel("get-master-addr-by-name", master_name)
    end
    let(:redis_info_result) do
      redis.info
    end
    before(:all) do
      server(:master).server.ssh_exec "sudo service redis stop"
      sleep 10
      server(:slave1).server.ssh_exec "sudo service redis stop"
      sleep 10
    end

    it "should be the master" do
      expect(sentinel_get_master_result).to eq([server(:slave2).server.address, "6379"])
      expect(redis_info_result["role"]).to eq("master")
      expect(redis_info_result["master_host"]).not_to eq(server(:master).server.address)
    end
  end
end
