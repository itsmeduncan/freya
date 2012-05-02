class Freya::QueryString
  attr_accessor :escape, :params

  ALIAS_PARAMS  = ['queries', 'phrases', 'filters', 'phrase_filters']
  ESCAPABLE_PARAMS = ['phrases', 'phrase_filters']
  GENERATE_KEY_PER_VALUE = ['fq', 'facet.field']

  FACET_PARAMS = ['facet', 'facet.field']
  PAGINATION_PARAMS = ['rows', 'start']
  NONTRANSFORMABLE_PARAMS = PAGINATION_PARAMS + FACET_PARAMS

  def initialize parameters
    params = HashWithIndifferentAccess.new parameters.dup
    
    @escape = transform_escape(params)
    
    transform_pagination(params)
    transform_facets(params) if params.key?(:facets)
    
    # TODO: Other parameters
    (params.keys - NONTRANSFORMABLE_PARAMS).each do |key|
      params[key] = transform(params[key], ESCAPABLE_PARAMS.include?(key))
    end
    
    @params = consolidate params
  end
  
  def to_s
    path = @params.collect do |key, value|
      case value
      when Array
        if GENERATE_KEY_PER_VALUE.include?(key)
          value.collect { |v| to_key_value(key, v) }
        else
          to_key_value(key, value.join(' '))
        end
      else
        to_key_value(key, value)
      end
    end

    "?" << path.join("&")
  end

  private

    def to_key_value key, value
      "#{key}=#{uri_escape(value)}"
    end

    def transform value, quote = false
      case value
      when Array
        value.collect { |val| transform(val, quote) }.flatten
      when Hash
        value.collect do |k,v|
          if v.is_a?(Range)
            "#{k}:[#{v.min} TO #{v.max}]"
          else
            quote ? "#{k}:#{quote(v)}" : "#{k}:#{v}"
          end
        end
      else
        quote ? [quote(value.to_s)] : [value.to_s]
      end
    end
    
    def consolidate params
      consolidated_params = params.dup

      consolidated_params[:q] = (params[:q] || []) + (params[:queries] || []) + (params[:phrases] || [])
      consolidated_params[:fq] = (params[:fq] || []) + (params[:filters] || []) + (params[:phrase_filters] || [])

      ALIAS_PARAMS.each { |key| consolidated_params.delete(key) }

      consolidated_params.delete(:q) if consolidated_params[:q].empty?
      consolidated_params.delete(:fq) if consolidated_params[:fq].empty?

      consolidated_params
    end

    def quote value
      %{"#{value}"}
    end

    def transform_pagination params
      page, per_page = params.delete(:page), params.delete(:per_page)

      if page && per_page
        params[:start] = (page.to_i - 1) * per_page.to_i
        params[:rows]  = per_page.to_i
      elsif per_page
        params[:rows]  = per_page.to_i
      end
    end
    
    def transform_facets params
      facets = params.delete(:facets)

      params[:facet] = true
      params["facet.field"] = facets[:fields]
    end
    
    def transform_escape params
      params.key?(:escape) ? params.delete(:escape) : true
    end
    
    def uri_escape string
      return string unless @escape
      string.to_s.gsub(/([^ a-zA-Z0-9_.-]+)/n) {
        '%'+$1.unpack('H2' * $1.size).join('%').upcase
      }.tr(' ', '+')
    end

end
