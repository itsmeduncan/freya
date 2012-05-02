require 'spec_helper'

describe Freya::Configuration do
  
  describe "meta methods" do
    it "should create accessors for each valid configuration option" do
      config = Freya::Configuration.new
      Freya::Configuration::VALID_OPTIONS.each do |option|
        config.respond_to?(option).should be_true
        config.respond_to?(:"#{option}=").should be_true
      end
    end
  end
  
  describe ".new" do
    it "should set the values properly for all valid options" do
      config = Freya::Configuration.new('type' => 'master')
      config.type.should == 'master'
    end
    
    it "should not try to set invalid options" do
      lambda {
        Freya::Configuration.new('fake' => 'danger bay')
      }.should raise_exception(ArgumentError)
    end
  end
  
  {
    :type => Freya::Configuration::VALID_TYPES, 
    :request_method => Freya::Configuration::VALID_REQUEST_METHODS,
    :response_format => Freya::Configuration::VALID_RESPONSE_FORMATS
  }.each do |param, valid_params|
    describe "validate :#{param}" do
      valid_params.each do |p|
        it "#{p} should be a valid #{param}" do
          lambda {
            Freya::Configuration.new(param.to_s => p)
          }.should_not raise_exception(ArgumentError)
        end
      end

      it "should raise an argument error for an invalid #{param}" do
        lambda {
          Freya::Configuration.new(param.to_s => "foo")
        }.should raise_exception(ArgumentError)
      end
    end

  end
  
  describe "defaults" do
    Freya::Configuration::DEFAULT_ATTRIBUTES.each do |option, default|
      it "should have the default value for #{option}" do
        Freya::Configuration.new.send(option).should == default
      end
    end
  end
  
  describe "#url" do
    it "should return the host and port" do
      Freya::Configuration.new("host" => "banana", "port" => "33900").url.should == "banana:33900"
    end
  end
  
end
