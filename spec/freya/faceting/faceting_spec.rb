require 'spec_helper'

describe Freya::Faceting do
  before do
    @hash = {
      "facet_counts" => {
        "facet_fields" => {
          "congress_number_i" => ["111", 2, "112", 1]
        }, 
        "facet_dates" => {:baz => :bop}, 
        "facet_queries"=> {:foo => :bar}
      }
    }
  end
  
  describe ".from_hash" do
    it "should call .new with the parameters" do
      Freya::Faceting.expects(:new).with(anything).returns(stub(:faceted => anything))
      Freya::Faceting.from_hash(anything)
    end
    
    it "should call #faceted on the new Freya::Faceting object" do
      mocked_facets = stub
      Freya::Faceting.stubs(:new).returns(mocked_facets)
      mocked_facets.expects(:faceted)
      Freya::Faceting.from_hash(anything)
    end
  end
  
  describe "#faceted" do
        
    it "should return the :hits for all the :items" do
      Freya::Faceting.from_hash(@hash).first.items.collect(&:hits).should == [2,1]
    end
    
    it "should return the :values for all the :items" do
      Freya::Faceting.from_hash(@hash).first.items.collect(&:value).should == ["111", "112"]
    end
    
    it "should " do
      Freya::Faceting.from_hash(@hash).collect(&:value).should == ["congress_number_i"]
    end    
  end
  
  describe "#facet_counts" do
    it "should return the counts" do
      Freya::Faceting.new(@hash).send(:facet_counts).should == {"facet_fields"=>{"congress_number_i"=>["111", 2, "112", 1]}, "facet_dates"=>{:baz=>:bop}, "facet_queries"=>{:foo=>:bar}}
    end
  end
  
  describe "#facet_fields" do
    it "should return the fields" do
      Freya::Faceting.new(@hash).send(:facet_fields).should == {"congress_number_i"=>["111", 2, "112", 1]}
    end    
  end
  
  describe "#facet_queries" do
    it "should return the queries" do
      Freya::Faceting.new(@hash).send(:facet_queries).should == {:foo => :bar}
    end        
  end
  
  describe "Freya::Faceting::Item" do
    [:hits, :items].each do |method|
      it "should response to #{method} and return" do
        Freya::Faceting::Item.new(:foo, :bar).send(method).should == :bar
      end
    end
  end
  
end
