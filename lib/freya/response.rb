class Freya::Response
  DEFAULTS = {
    :rows => 10,
    :start => 0,
    :total => 0
  }
  
  attr_reader :response_object
  
  def initialize response_object
    @response_object = HashWithIndifferentAccess.new response_object
  end

  def docs
    WillPaginate::Collection.create(page, per_page, total) do |pager|
      begin
        pager.replace @response_object["response"]["docs"]
      rescue Exception => e
        Freya.logger.error "Freya Exception in #docs: #{e.message}"
        pager.replace []
      end
    end
  end

  def facets
    @facets ||= Freya::Faceting.from_hash @response_object
  end
  
  def total
    @total ||= from_param(@response_object["response"]["numFound"]) rescue DEFAULTS[:total]
  end

  def page
    start = from_param(@response_object["responseHeader"]["params"]["start"]) rescue DEFAULTS[:start]

    @page ||= (start / per_page) + 1
  end
  
  def per_page
    @per_page ||= from_param(@response_object["responseHeader"]["params"]["rows"]) rescue DEFAULTS[:rows]
  end

  def query_time
    @query_time ||= from_param(@response_object["responseHeader"]["QTime"]) rescue nil
  end

  def [](key)
    @response_object[key.to_s]
  end
  
  def method_missing method, *args, &block
    if respond_to? method
      Freya.logger.debug "Deprecated method call on Freya::Response: #{method}\t#{args.inspect}"
      @response_object[method.to_s]
    else
      super
    end
  end
  
  def respond_to? method, include_private = false
    return true if @response_object.key?(method.to_s)
    super
  end
  
  private
  
    def from_param value
      value.to_i == 0 ? raise(ArgumentError) : value.to_i
    end
end