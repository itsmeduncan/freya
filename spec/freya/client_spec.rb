require 'spec_helper'

describe Freya::Client do
  
  before do
    @config = {
                "master" => [ {"host" => "localhost",  "port" => "33900"} ],
                "slave" => [ {"host" => "localhost",  "port" => "33900"} ]
              }
              
    @multi_slave_config = {
                "master" => [ {"host" => "localhost",  "port" => "33900"} ],
                "slave" => [ 
                  {"host" => "localhost",  "port" => "33900"}, 
                  {"host" => "banana.com",  "port" => "33901"}
                ]
              }
  end
  
  describe "connections for type" do
    Freya::Configuration::VALID_TYPES.each do |valid_type|
      it "should return a connection for #{valid_type}" do
        connection = Freya::Client.new(@config)
        connection.send(valid_type.to_sym).should be_a(Freya::Connection)
      end
    end

    it "should cycle through the available connections" do
      connection = Freya::Client.new(@multi_slave_config)

      ["localhost", "banana.com", "localhost"].each do |host|
        connection.slave.configuration.host.should == host
      end
    end
  end

  describe "connection pools" do
    Freya::Configuration::VALID_TYPES.each do |valid_type|
      it "should return connections for #{valid_type}" do
        Freya::Client.new(@config).send(:"#{valid_type}_connections").each do |pool|
          pool.should be_a(Freya::Connection)
        end
      end
    end
  end
  
  describe "ping" do
    it "should be called on the master connection" do
      client = Freya::Client.new(@config)
      client.master.expects(:ping)
      client.ping
    end
  end

  describe "ping?" do
    it "should be called on the master connection" do
      client = Freya::Client.new(@config)
      client.master.expects(:ping?)
      client.ping?
    end
  end

  describe "valid?" do
    it "should be called on the master connection" do
      client = Freya::Client.new(@config)
      client.master.expects(:valid?)
      client.valid?
    end
  end
  
  describe "#find" do
    it "should call select on a slave" do
      client = Freya::Client.new(@config)
      client.slave.expects(:select).with(anything).once
      client.find(anything)
    end
  end
  
  describe "#add" do
    it "should call update :add on the master" do
      client = Freya::Client.new(@config)
      client.master.expects(:update).with(:add, anything).once
      client.add(anything)
    end
  end
  
  describe "#commit" do
    it "should call update :commit on master" do
      client = Freya::Client.new(@config)
      client.master.expects(:update).with(:commit).once
      client.commit
    end
  end
  
  describe "#delete_by_query" do
    it "should raise a not implemented error" do
      client = Freya::Client.new(@config)
      client.master.expects(:update).with(:delete, has_key(:query))
      client.delete_by_query(anything)
    end
  end
  
  describe "#delete_by_id" do
    it "should raise a not implemented error" do
      client = Freya::Client.new(@config)
      client.master.expects(:update).with(:delete, has_key(:id))
      client.delete_by_id(anything)
    end
  end
  
  describe "#count" do
    it "should call :select" do
      client = Freya::Client.new(@config)
      client.slave.expects(:select).with(anything).once
      client.find(anything)      
    end

    it "should return the response's numFound" do
      client = Freya::Client.new(@config)
      client.slave.expects(:select).with(anything).once.returns({"response" => {"numFound" => 1} })
      client.count({}).should == 1
    end

    it "should return 0 when there is a problem" do
      client = Freya::Client.new(@config)
      client.slave.expects(:select).with(anything).once.returns({})
      client.count({}).should == 0
    end

    it "should pass :per_page as 0 when counting" do
      client = Freya::Client.new(@config)
      client.slave.expects(:select).with(has_entry(:per_page, 0)).once.returns({})
      client.count({}).should == 0
    end
  end

  describe "#optimize" do
    it "should call update :optimize on master" do
      client = Freya::Client.new(@config)
      client.master.expects(:update).with(:optimize).once
      client.optimize
    end
  end

  describe "only master" do
    before do
      @config = { "master" => [ {"host" => "localhost",  "port" => "33900"} ] }
    end

    it "should not throw an exception when there is no slave" do
      lambda {
        Freya::Client.new(@config)
      }.should_not raise_exception
    end

    it "should use the master as a slave when there are no slaves" do
      client = Freya::Client.new(@config)
      client.master.expects(:select).with(anything).once.returns({})
      client.count({}).should == 0
    end
  end

  describe "bad config" do
    it "should raise a bad config error when there is no master" do
      lambda {
        Freya::Client.new({ "slave" => [ {"host" => "localhost",  "port" => "33900"} ] })
      }.should raise_exception(ArgumentError)
    end

    it "should raise a bad config error when there is no config" do
      lambda {
        Freya::Client.new()
      }.should raise_exception(ArgumentError)
    end
  end
end
