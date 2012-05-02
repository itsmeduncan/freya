require 'spec_helper'

describe Freya::Document do
  
  describe "initialize" do
    it "should always make data an array" do
      Freya::Document.new(:add, 1).data.should == [1]
      Freya::Document.new(:add, [1]).data.should == [1]
    end

    Freya::Document::VALID_DOCUMENT_TYPES.each do |valid_type|
      it "should allow #{valid_type}" do
        lambda {
          Freya::Document.new(valid_type, {})
        }.should_not raise_exception(ArgumentError)
      end
    end

    it "should raise an argument error for a bad type" do
      lambda {
        Freya::Document.new(:foo, {})
      }.should raise_exception(ArgumentError)
    end
  end

  describe "#to_xml" do
    it "should format the document for :add" do
      xml = Nokogiri::XML("<xml></xml>")
      document = Freya::Document.new(:add, { :foo => :bar })

      document.expects(:default_document_format).once.returns(xml)
      xml.expects(:to_xml)

      document.to_xml
    end
    
    it "should format the document for :delete" do
      xml = Nokogiri::XML("<xml></xml>")
      document = Freya::Document.new(:delete, { :foo => :bar })

      document.expects(:delete_document_format).once.returns(xml)
      xml.expects(:to_xml)

      document.to_xml
    end
  end
  
  describe "#default_document_format" do
    it "should have the proper field :name and :value" do
      xml = Nokogiri::XML(Freya::Document.new(:add, { :foo => :bar }).to_xml)
      xml.at("//add/doc/field[@name='foo']").inner_text.should == "bar"
    end
    
    it "should handle multiple documents" do
      xml = Nokogiri::XML(Freya::Document.new(:add, [{ :foo => :bar }, { :foo => :bar }]).to_xml)
      xml.xpath("//add/doc").length.should == 2
    end
    
    it "should filter out blank values" do
      xml = Nokogiri::XML(Freya::Document.new(:add, { :foo => nil }).to_xml)
      xml.xpath("//add/doc/field[@name='foo']").length.should == 0
    end

    it "should comma seperate array values" do
      xml = Nokogiri::XML(Freya::Document.new(:add, { :foo => [1,2,3] }).to_xml)
      xml.xpath("//add/doc/field[@name='foo']").length.should == 3
    end
  end
  
  describe "#delete_document_format" do
    it "should have the correct format for :id" do
      xml = Nokogiri::XML(Freya::Document.new(:delete, {:id => 1}).to_xml)
      xml.at("//delete/id").inner_text.should == "1"
    end

    it "should filter out blank values" do
      xml = Nokogiri::XML(Freya::Document.new(:delete, { :id => nil }).to_xml)
      xml.xpath("//delete/id").length.should == 0
    end
    
    it "should handle multiple :ids" do
      xml = Nokogiri::XML(Freya::Document.new(:delete, {:id => [1, 2]}).to_xml)
      xml.xpath("//delete/id").length.should == 2
    end
    
    it "should handle multiple :ids with blanks" do
      xml = Nokogiri::XML(Freya::Document.new(:delete, {:id => [1, 2, nil]}).to_xml)
      xml.xpath("//delete/id").length.should == 2      
    end
    
    it "should handle :query and :id" do
      xml = Nokogiri::XML(Freya::Document.new(:delete, {:query => "foo:bar", :id => 1}).to_xml)
      xml.at("//delete/id").inner_text.should == "1"
      xml.at("//delete/query").inner_text.should == "foo:bar"
    end
    
    it "should handle multiple :query and :id params" do
      xml = Nokogiri::XML(Freya::Document.new(:delete, {:query => ["foo:bar", "baz:fun"], :id => [1,2]}).to_xml)
      xml.xpath("//delete/id").length.should == 2
      xml.xpath("//delete/query").length.should == 2
    end
  end
  
end
