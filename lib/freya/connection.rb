class Freya::Connection
  attr_reader :configuration
  
  POST_CONTENT_TYPE = "text/xml"

  def initialize configuration
    @configuration = configuration
  end

  def admin path, params = {}
    result = query("/solr/admin/#{path}", :params => params)
    formatted(result)
  end
  
  def select params
    result = query("/solr/select", :params => params)
    formatted(result)
  end
  
  def update type, data = []
    result = query("/solr/update", :data => Freya::Document.new(type, data).to_xml)
    formatted(result)
  end

  def ping
    admin('ping')
  end

  def ping?
    ping['status'] == 'OK'
  rescue Exception => e
    Freya.logger.error "Freya Exception in #ping?: #{e.message}"
    false
  end
  alias_method :valid?, :ping?
  
  private

    def query path, options = {}
      response = Net::HTTP.start(configuration.host, configuration.port) do |http|
        http.read_timeout = configuration.timeout
        http.request build_request(path, options)
      end
      
      raise Exception.new("Bad response code (#{response.code}) received!") unless response.code == '200'

      response.body
    rescue NotImplementedError => not_implemented
      raise not_implemented
    rescue Exception => e
      Freya.logger.error "Freya Exception in #query: #{e.message}"
      configuration.raise_exceptions ? raise(e) : empty_response
    end

    def build_request path, options = {}
      params = options.delete(:params) || {}
      data   = options.delete(:data)
      uri    = uri(path, params)

      Freya.logger.info  "Freya Request\t#{configuration.request_method.to_s.upcase} #{uri}"
      Freya.logger.debug "Freya Raw Params\t#{params.inspect}"
      Freya.logger.debug "Freya Data\t#{data}"

      case configuration.request_method
      when :post
        request_object = Net::HTTP::Post.new(uri)
        request_object.body = data
        request_object.content_type = POST_CONTENT_TYPE
      when :get
        request_object = Net::HTTP::Get.new(uri)
      else
        raise NotImplementedError
      end

      request_object
    end
    
    def uri path, params, escape = true
      query_params = default_options.merge(params).merge(:escape => escape)
      [ path, Freya::QueryString.new(query_params).to_s ].join
    end

    def default_options
      { :wt => @configuration.response_format }
    end

    def formatted result
      response = case @configuration.response_format
      when :ruby
        Kernel.eval(result)
      when :json
        JSON.parse(result)
      when :xml
        Nokogiri::XML.parse(result)
      else
        raise NotImplementedError
      end
      Freya::Response.new(response)
    rescue Exception => e
      raise(e)
    end
    
    def empty_response
      "{'response'=>{'start'=>0, 'docs'=>[], 'numFound'=>0}, 'responseHeader'=>{'QTime'=>0, 'params'=>{'facet'=>'true', 'q'=>'', 'wt'=>'ruby', 'rows'=>'0'}, 'status'=>0}, 'facet_counts'=>{'facet_fields'=>{'section'=>[]}, 'facet_dates'=>{}, 'facet_queries'=>{}}}"
    end
    
end