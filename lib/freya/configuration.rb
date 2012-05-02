class Freya::Configuration
  VALID_OPTIONS = [ :type, :host, :port, :timeout, :request_method, :raise_exceptions, :response_format ]
  VALID_TYPES = [ "master", "slave" ]
  VALID_REQUEST_METHODS = [ :get, :post ]
  VALID_RESPONSE_FORMATS = [ :ruby, :json, :xml ]

  VALIDATIONS = { 
    "type" => lambda { |type| VALID_TYPES.include?(type) },
    "request_method" => lambda { |method| VALID_REQUEST_METHODS.include?(method) },
    "response_format" => lambda { |method| VALID_RESPONSE_FORMATS.include?(method) }
  }
  
  DEFAULT_ATTRIBUTES = {
    "type" => "master",
    "host" => "localhost",
    "port" => 33900,
    "timeout" => 10,
    "request_method" => :get,
    "raise_exceptions" => true,
    "response_format" => :ruby
  }.freeze

  attr_accessor *VALID_OPTIONS

  def initialize(options = {})
    attributes = DEFAULT_ATTRIBUTES.merge(options)
    
    attributes.each do |option, value|
      if VALID_OPTIONS.include?(option.to_sym) 
        if validate_options(option, value)
          send(:"#{option}=", value)
        else
          raise ArgumentError.new("#{option} with value #{value} is invalid")
        end
      else
        raise ArgumentError.new("#{option} is an invalid option for #{self.class.name}")
      end
    end
  end
  
  def url
    "#{host}:#{port}"
  end
  
  private
    
    def validate_options option, value
      !VALIDATIONS[option] || ( VALIDATIONS[option] && VALIDATIONS[option].call(value) )
    end
end