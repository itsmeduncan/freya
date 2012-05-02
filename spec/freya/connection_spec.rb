require 'spec_helper'

describe Freya::Connection do

  before :each do
    @configuration = Freya::Configuration.new(
      "host" => "localhost",
      "port" => 99999,
      "timeout" => 60,
      "request_method" => :post,
      "raise_exceptions" => false
    )
  end
  
  describe "#admin" do
    it "should call query with the correct params" do
      connection = Freya::Connection.new(@configuration)
      connection.expects(:query).with("/solr/admin/foo", :params => {}).returns("")
      connection.admin("foo")
    end
  end
  
  describe "#select" do
    it "should call query with the correct params" do
      connection = Freya::Connection.new(@configuration)
      connection.expects(:query).with("/solr/select", :params => {:foo => :bar}).returns("")
      connection.select(:foo => :bar)
    end
  end
  
  describe "#update" do
    it "should call query with the correct params" do
      connection = Freya::Connection.new(@configuration)
      connection.expects(:query).with("/solr/update", has_entries(:data => anything)).returns("")
      connection.update(:add, [:foo => :bar])
    end
  end

  describe "#ping" do
    it "should be pingable" do
      connection = Freya::Connection.new(@configuration)
      connection.expects(:admin).with('ping')
      connection.ping
    end
  end

  describe "#ping?" do
    it "should ping and check for status 'OK'" do
      connection = Freya::Connection.new(@configuration)
      connection.expects(:admin).with('ping').returns({"status" => 'OK'})
      connection.should be_ping
    end

    it "should ping with a connection, fail and return false" do
      connection = Freya::Connection.new(@configuration)
      connection.expects(:admin).with('ping').returns({"status" => 'foo'})
      connection.should_not be_ping
    end

    it "should ping without a connection, raise but return false" do
      connection = Freya::Connection.new(@configuration)
      connection.expects(:admin).with('ping').raises
      connection.should_not be_ping
    end

    it "should be aliased as #valid?" do
      connection = Freya::Connection.new(@configuration)
      connection.expects(:admin).with('ping').returns({"status" => 'OK'})
      connection.should be_valid
    end
  end

  describe "#formatted" do
    it "should Kernel#eval the response" do
      configuration = Freya::Configuration.new(
        "response_format" => :ruby
      )

      mock_http_response = stub(:body => "{:foo => :bar}")

      Kernel.expects(:eval).with(mock_http_response.body)
      Freya::Connection.new(configuration).send(:formatted, mock_http_response.body)
    end

    it "should JSON parse the response" do
      configuration = Freya::Configuration.new(
        "response_format" => :json
      )

      mock_http_response = stub(:body => "{:foo => :bar}")

      JSON.expects(:parse).with(mock_http_response.body)

      Freya::Connection.new(configuration).send(:formatted, mock_http_response.body)
    end

    it "should XML parse the response" do
      configuration = Freya::Configuration.new(
        "response_format" => :xml
      )

      mock_http_response = stub(:body => "<foo>bar</foo>")

      Nokogiri::XML.expects(:parse).with(mock_http_response.body)

      Freya::Connection.new(configuration).send(:formatted, mock_http_response.body)
    end

    it "should raise if the format is invalid" do
      mock_http_response = stub(:body => "{:foo => :bar}")

      configuration = Freya::Configuration.new
      configuration.stubs(:response_format).returns(:foo)

      lambda {
        Freya::Connection.new(configuration).send(:formatted, mock_http_response.body)
      }.should raise_exception(NotImplementedError)
    end
  end
  
  describe "#uri" do
    it "should generate a valid uri from path & params" do
      Freya::Connection.new(@configuration).send(:uri, 'foo', {:bar => :baz}, false).should =~ /foo\?.*bar=baz.*/
    end
    
    it "should include the default params" do
      Freya::Connection.new(@configuration).send(:uri, 'foo', {:bar => :baz}, false).should =~ /wt=ruby/
    end
    
    it "should escape the params" do
      Freya::QueryString.expects(:new).with(has_entries(:escape => true))
      Freya::Connection.new(@configuration).send(:uri, anything, {})
    end
  end
  
  describe "#build_request" do
    it "should build the correct request for a GET" do
      Net::HTTP::Get.expects(:new).with(regexp_matches(/^foo/))
      
      @configuration.request_method = :get
      Freya::Connection.new(@configuration).send(:build_request, 'foo')
    end
    
    it "should build the correct request for a POST" do
      @configuration.request_method = :post
      mock_response = stub
      
      Net::HTTP::Post.expects(:new).with(regexp_matches(/^foo/)).returns(mock_response)
      mock_response.expects(:body=).with(:my_data)
      mock_response.expects(:content_type=).with(Freya::Connection::POST_CONTENT_TYPE)
      
      Freya::Connection.new(@configuration).send(:build_request, 'foo', :data => :my_data)
    end
    
    it "should raise an error for an unknown request method" do
      @configuration.request_method = :foo
      
      lambda {
        Freya::Connection.new(@configuration).send(:build_request, anything)
      }.should raise_exception(NotImplementedError)
    end
  end
  
  describe "#query" do
    it "should start a connection to the right host:port" do
      Net::HTTP.expects(:start).with(@configuration.host, @configuration.port)
      Freya::Connection.new(@configuration).send(:query, anything)
    end
    
    it "should start a connection to the right host:port" do
      mock_http_request = stub(:read_timeout= => anything)
      Net::HTTP.expects(:start).yields(mock_http_request)
      
      mock_http_request.expects(:request)
      Freya::Connection.new(@configuration).send(:query, anything)
    end
    
    it "should set the timeout" do
      mock_http_request = stub(:request => anything)
      Net::HTTP.expects(:start).yields(mock_http_request)
      
      mock_http_request.expects(:read_timeout=).with(@configuration.timeout)
      
      Freya::Connection.new(@configuration).send(:query, anything)      
    end
    
    it "should raise an exception when the response code is not 200" do
      configuration = @configuration
      
      mock_http_response = stub(:body => anything, :code => '500')
      Net::HTTP.expects(:start).returns(mock_http_response)
  
      configuration.raise_exceptions = true
      lambda {
        Freya::Connection.new(@configuration).send(:query, anything)
      }.should raise_exception
    end
    
    it "should not raise an exception when there is a good response" do
      configuration = @configuration
      
      mock_http_response = stub(:body => anything, :code => '200')
      Net::HTTP.expects(:start).returns(mock_http_response)
  
      configuration.raise_exceptions = true
      lambda {
        Freya::Connection.new(@configuration).send(:query, anything)
      }.should_not raise_exception
    end
    
    it "should not raise errors when configured to supress them" do
      configuration = @configuration
      
      mock_http_response = stub(:body => anything, :code => '500')
      Net::HTTP.expects(:start).returns(mock_http_response)
  
      configuration.raise_exceptions = false
      lambda {
        Freya::Connection.new(@configuration).send(:query, anything)
      }.should_not raise_exception
    end
    
    it "should raise any NotImplementedError exception regardless fo the raise_exception setting" do
      configuration = @configuration
      configuration.raise_exceptions = false
      configuration.request_method = :head
      
      mock_http_response = stub(:body => anything, :code => '500')
      Net::HTTP.expects(:start).raises(NotImplementedError)
  
      lambda {
        Freya::Connection.new(@configuration).send(:query, anything)
      }.should raise_exception(NotImplementedError)
    end
  end
  
  describe "default_options" do
    it "should have default options that include wt" do
      Freya::Connection.new(@configuration).send(:default_options)[:wt].should == :ruby
    end
  end
  
  describe "configuration#raise_exceptions" do
    it "should raise exceptions when configured to do such a thing" do
      configuration = @configuration
      configuration.raise_exceptions = true
        
      connection = Freya::Connection.new(configuration)
      lambda {
        connection.select(:q => 'entity_type:*')
      }.should raise_exception
    end
    
    it "should not raise exceptions when told not too" do
      configuration = @configuration
      configuration.raise_exceptions = false
        
      connection = Freya::Connection.new(configuration)
      lambda {
        connection.select(:q => 'entity_type:*')
      }.should_not raise_exception
    end
  end
   
end