require 'spec_helper'

describe Freya::Response do
  
  describe "#method_missing" do
    it "should return the value for the key" do
      Freya::Response.new({"foo" => "bar"}).foo.should == "bar"
    end
    
    it "should raise a NoMethodError when the method isn't a key" do
      lambda {
        Freya::Response.new({"foo" => "bar"}).baz
      }.should raise_exception(NoMethodError)
    end
  end
  
  describe "#respond_to?" do
    it "should respond to the passed in keys" do
      Freya::Response.new({"foo" => "bar"}).should respond_to(:foo)
    end
    
    it "shouldn't respond to keys not given" do
      Freya::Response.new({"foo" => "bar"}).should_not respond_to(:baz)
    end
  end
  
  describe "#docs" do
    it "should return the docs" do
      response = Freya::Response.new({"response" => { "docs" => [:bar] }})
      response.stubs(:page).returns(1)
      response.stubs(:per_page).returns(1)
      response.docs.should == [:bar]
    end
    
    it "should return an empty array if there is no docs" do
      response = Freya::Response.new({"response" => { "foo" => [:bar] }})
      response.docs.should == []
    end

    [:current_page, :per_page, :total_entries, :total_pages].each do |will_paginate_method|
      it "should respond to #{will_paginate_method} even when there are no docs" do
        Freya::Response.new({"response" => { "foo" => [:bar] }}).docs.should respond_to(will_paginate_method)
      end
    end

    it "should not raise an error when the hash is not recognized" do
      lambda {
        Freya::Response.new({}).docs
      }.should_not raise_exception
    end
  end
  
  describe "#[]()" do
    it "should return the value for the key" do
      Freya::Response.new({ "foo" => "bar" })[:foo].should == "bar"
    end
    
    it "should handle nested hashes" do
      Freya::Response.new({ "foo" => { "bar" => "baz" } })["foo"]["bar"].should == "baz"
    end
  end
  
  describe "#facets" do
    it "should call :from_hash on Freya::Faceting" do
      Freya::Faceting.expects(:from_hash).with(anything)
      Freya::Response.new(anything).facets
    end
  end
  
  describe "#page" do
    it "should return the page" do
      Freya::Response.new({ "responseHeader" => { "params" => { "start" => 20, "rows" => 10 } } }).page.should == 3
    end
    
    it "should return the default page" do
      Freya::Response.new({}).page.should == Freya::Response::DEFAULTS[:start] + 1
    end
  end

  describe "#per_page" do
    it "should return the per page" do
      Freya::Response.new({ "responseHeader" => { "params" => { "rows" => "5" } } }).per_page.should == 5
    end    

    it "should return the default per page" do
      Freya::Response.new({}).per_page.should == Freya::Response::DEFAULTS[:rows]
    end
  end

  describe "#total" do
    it "should return the total number found" do
      Freya::Response.new({ "response" => { "numFound" => 11 } }).total.should == 11
    end

    it "should return the default per page" do
      Freya::Response.new({}).total.should == Freya::Response::DEFAULTS[:total]
    end
  end
  
  describe "#from_param" do
    it "should use the passed in value" do
      Freya::Response.new(anything).send(:from_param, 10).should == 10
    end
    
    [nil, "", 0].each do |value|
      it "should use the default when given '#{value.inspect}'" do
        lambda {
          Freya::Response.new(anything).send(:from_param, value)
        }.should raise_exception
      end
    end
  end

  describe "#query_time" do
    it "should return the query time from the response" do
      Freya::Response.new({ "responseHeader" => { "QTime" => "11" } }).query_time.should == 11
    end

    it "should return nil if there is no query time" do
      Freya::Response.new({ "responseHeader" => {} }).query_time.should be_nil
    end
  end

  describe "indifferent access" do
    describe "string lookup" do
      it "should handle symbols" do
        Freya::Response.new({ :foo => "bar" })["foo"].should == "bar"
      end

      it "should handle strings" do
        Freya::Response.new({ "foo" => "bar" })["foo"].should == "bar"
      end
    end
    
    describe "symbol lookup" do
      it "should handle symbols" do
        Freya::Response.new({ :foo => "bar" })[:foo].should == "bar"
      end

      it "should handle strings" do
        Freya::Response.new({ "foo" => "bar" })[:foo].should == "bar"
      end
    end
    
    it "should work in the real world" do
      response = Freya::Response.new({"start"=>0, "docs"=>[{"entity_id_i"=>3, "active_code_s"=>"CA"}], "numFound"=>1})
      response['docs'].collect { |doc| doc[:entity_id_i] }.should == [3]
    end
  end
  
end
