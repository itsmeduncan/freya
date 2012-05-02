require 'spec_helper'

describe Freya::QueryString do

  describe "pagination" do
    it "should set start based on the :page and :per_page parameter" do
      query_string = Freya::QueryString.new(:page => '9', :per_page => '10')  
      query_string.params[:start].should == 80
    end
  
    it "should not set start if there is no :per_page parameter" do
      Freya::QueryString.new(:page => '9').params.key?(:start).should be_false
    end
  
    it "should not set start if the value is nil" do
      Freya::QueryString.new(:page => nil, :per_page => '10').params.key?(:start).should be_false
    end
    
    it "should set rows to :per_page in the query string" do
      Freya::QueryString.new(:per_page => '10').params[:rows].should == 10
    end
  
    it "should not set per_page if the value is nil" do
      Freya::QueryString.new(:per_page => nil).params.key?(:rows).should be_false
    end

    it "should remove the :page and :per_page parameters" do
      query_string = Freya::QueryString.new(:page => 1, :per_page => 10)
      query_string.params[:page].should be_nil
      query_string.params[:per_page].should be_nil
    end
  end
  
  describe "escape" do
    it "should set escape to true" do
      Freya::QueryString.new(:escape => true).escape.should be
    end
    
    it "should set escape to false if there is no escape param" do
      Freya::QueryString.new({}).escape.should be
    end
    
    it "should set escape " do
      Freya::QueryString.new(:escape => false).escape.should_not be
    end
  end
  
  describe "facets" do
    it "should add facets:true of there are facets" do
      Freya::QueryString.new(:facets => {:fields => :foo}).params[:facet].should be
    end

    it "should add the facets fields to 'facet.field'" do
      Freya::QueryString.new(:facets => {:fields => :foo}).params["facet.field"].should == :foo
    end

    it "should remove the :facets parameter" do
      Freya::QueryString.new(:facets => {:fields => :foo}).params[:facets].should be_nil
    end
  end
  
  describe "q" do
    it "should be able to take a string" do
      Freya::QueryString.new(:q => 'foo').params[:q].should == ['foo']
    end
    
    it "should be able to take an array" do
      Freya::QueryString.new(:q => ['foo', 'bar']).params[:q].should == ['foo', 'bar']
    end
    
    it "should be able to take a hash" do
      Freya::QueryString.new(:q => {:foo => 'bar'}).params[:q].should == ['foo:bar']
    end
    
    it "should be able to take a complex object" do
      Freya::QueryString.new(:q => [ 'baz', {:foo => 'bar'} ]).params[:q].should == ['baz', 'foo:bar']
    end

    it "should be able to handle a Range" do
      Freya::QueryString.new(:q => {:foo => 0..10 }).params[:q].should == ['foo:[0 TO 10]']
    end
  end
  
  describe "queries" do
    it "should be able to take a string" do
      Freya::QueryString.new(:queries => 'foo').params[:q].should == ['foo']
    end
    
    it "should be able to take an array" do
      Freya::QueryString.new(:queries => ['foo', 'bar']).params[:q].should == ['foo', 'bar']
    end
    
    it "should be able to take a hash" do
      Freya::QueryString.new(:queries => {:foo => 'bar'}).params[:q].should == ['foo:bar']
    end

    it "should be able to take a complex object" do
      Freya::QueryString.new(:queries => [ 'baz', {:foo => 'bar'} ]).params[:q].should == ['baz', 'foo:bar']
    end

    it "should be able to handle a Range" do
      Freya::QueryString.new(:queries => {:foo => 0..10 }).params[:q].should == ['foo:[0 TO 10]']
    end
  end

  describe "fq" do
    it "should be able to take a string" do
      Freya::QueryString.new(:fq => 'foo').params[:fq].should == ['foo']
    end
    
    it "should be able to take an array" do
      Freya::QueryString.new(:fq => ['foo', 'bar']).params[:fq].should == ['foo', 'bar']
    end
    
    it "should be able to take a hash" do
      Freya::QueryString.new(:fq => {:foo => 'bar'}).params[:fq].should == ['foo:bar']
    end
    
    it "should be able to take a complex object" do
      Freya::QueryString.new(:fq => [ 'baz', {:foo => 'bar'} ]).params[:fq].should == ['baz', 'foo:bar']
    end
  end

  describe "filters" do
    it "should be able to take a string" do
      Freya::QueryString.new(:filters => 'foo').params[:fq].should == ['foo']
    end
    
    it "should be able to take an array" do
      Freya::QueryString.new(:filters => ['foo', 'bar']).params[:fq].should == ['foo', 'bar']
    end
    
    it "should be able to take a hash" do
      Freya::QueryString.new(:filters => {:foo => 'bar'}).params[:fq].should == ['foo:bar']
    end
    
    it "should be able to take a complex object" do
      Freya::QueryString.new(:filters => [ 'baz', {:foo => 'bar'} ]).params[:fq].should == ['baz', 'foo:bar']
    end
  end

  describe "phrases" do
    it "should be able to take a string" do
      Freya::QueryString.new(:phrases => 'foo').params[:q].should == ['"foo"']
    end
    
    it "should be able to take an array" do
      Freya::QueryString.new(:phrases => ['foo', 'bar']).params[:q].should == ['"foo"', '"bar"']
    end
    
    it "should be able to take a hash" do
      Freya::QueryString.new(:phrases => {:foo => 'bar'}).params[:q].should == ['foo:"bar"']
    end
    
    it "should be able to take a complex object" do
      Freya::QueryString.new(:phrases => [ 'baz', {:foo => 'bar'} ]).params[:q].should == ['"baz"', 'foo:"bar"']
    end
  end

  describe "phrase_filters" do
    it "should be able to take a string" do
      Freya::QueryString.new(:phrase_filters => 'foo').params[:fq].should == ['"foo"']
    end
    
    it "should be able to take an array" do
      Freya::QueryString.new(:phrase_filters => ['foo', 'bar']).params[:fq].should == ['"foo"', '"bar"']
    end
    
    it "should be able to take a hash" do
      Freya::QueryString.new(:phrase_filters => {:foo => 'bar'}).params[:fq].should == ['foo:"bar"']
    end
    
    it "should be able to take a complex object" do
      Freya::QueryString.new(:phrase_filters => [ 'baz', {:foo => 'bar'} ]).params[:fq].should == ['"baz"', 'foo:"bar"']
    end    
  end

  describe "consolidate parameters" do
    describe ":q" do
      it "should merge :queries into :q" do
        Freya::QueryString.new(:queries => 'baz').params[:q].should == ['baz']
      end

      it "should handle complex :q and :queries" do
        Freya::QueryString.new(:q => [ 'baz', {:foo => 'bar'} ], :queries => 'banana' ).params[:q].sort.should == ["banana", "baz", "foo:bar"]
      end
      
      it "should merge :queries into :q" do
        Freya::QueryString.new(:phrases => 'baz').params[:q].should == ['"baz"']
      end

      it "should handle complex :q and :phrases" do
        Freya::QueryString.new(:q => [ 'baz', {:foo => 'bar'} ], :phrases => 'banana' ).params[:q].sort.should == ['"banana"', "baz", "foo:bar"]
      end

      it "should handle complex :q, :queries, and :phrases" do
        Freya::QueryString.new(:q => [ 'I', {:foo => 'like'} ], :queries => ['black'], :phrases => 'bananas').params[:q].sort.should == ['"bananas"', 'I', 'black', "foo:like"]
      end

      it "should remove the :queries parameter" do
        Freya::QueryString.new(:queries => 'foo').params.key?(:queries).should be_false
      end

      it "should remove the :phrases parameter" do
        Freya::QueryString.new(:phrases => 'foo').params.key?(:phrases).should be_false
      end
    end
    
    describe ":fq" do
      it "should merge :filters into :fq" do
        Freya::QueryString.new(:filters => 'baz').params[:fq].should == ['baz']
      end

      it "should handle complex :fq and :filters" do
        Freya::QueryString.new(:fq => [ 'baz', {:foo => 'bar'} ], :filters => 'banana' ).params[:fq].sort.should == ["banana", "baz", "foo:bar"]
      end
      
      it "should merge :phrase_filters into :fq" do
        Freya::QueryString.new(:phrase_filters => 'baz').params[:fq].should == ['"baz"']
      end

      it "should handle complex :fq and :phrase_filters" do
        Freya::QueryString.new(:fq => [ 'baz', {:foo => 'bar'} ], :phrase_filters => 'banana' ).params[:fq].sort.should == ['"banana"', "baz", "foo:bar"]
      end

      it "should handle complex :q, :filters, and :phrase_filters" do
        Freya::QueryString.new(:fq => [ 'I', {:foo => 'like'} ], :filters => ['black'], :phrase_filters => 'bananas').params[:fq].sort.should == ['"bananas"', 'I', 'black', "foo:like"]
      end

      it "should remove the :filters parameter" do
        Freya::QueryString.new(:filters => 'foo').params.key?(:filters).should be_false
      end

      it "should remove the :phrase_filters parameter" do
        Freya::QueryString.new(:phrase_filters => 'foo').params.key?(:phrase_filters).should be_false
      end
    end
  end

  describe "#to_s" do
    it "should handle special single value parameters" do
      Freya::QueryString.new(:page => 1, :per_page => 10, :escape => false).to_s.should == '?start=0&rows=10'
    end

    it "should auto join values for :q" do
      Freya::QueryString.new(:q => ['foo', 'bar'], :escape => false).to_s.should == '?q=foo bar'
    end

    it "should not auto join values for :fq" do
      query_string = Freya::QueryString.new(:fq => ['foo', 'bar'], :escape => false).to_s
      query_string.should =~ /fq=foo/
      query_string.should =~ /fq=bar/
    end

    it "should not auto join values for :'facet.field'" do
      query_string = Freya::QueryString.new('facet.field' => ['foo', 'bar'], :escape => false).to_s
      query_string.should =~ /facet.field=foo/
      query_string.should =~ /facet.field=bar/
    end

    it "should handle multiple params" do
      query_string = Freya::QueryString.new(:q => ['foo', 'bar'], :fq => [ 'I', {:foo => 'like'} ], :escape => false).to_s
      query_string.should =~ /fq=I/
      query_string.should =~ /fq=foo:like/
      query_string.should =~ /q=foo bar/
    end

    it "should handle any parameter" do
      Freya::QueryString.new(:foo => 'bar').to_s.should == '?foo=bar'
    end

    it "should handle true/false parameters" do
      query_string = Freya::QueryString.new(:bar => false, :baz => true).to_s
      query_string.should =~ /baz=true/
      query_string.should =~ /bar=false/
    end
  end
end
