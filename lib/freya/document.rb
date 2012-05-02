class Freya::Document
  attr_reader :type, :data
  
  VALID_DOCUMENT_TYPES = [:add, :update, :delete, :optimize, :commit]
  
  def initialize type, data
    @type = type
    raise ArgumentError unless VALID_DOCUMENT_TYPES.include?(@type)

    @data = data.is_a?(Array) ? data : [data]
  end
  
  def to_xml
    document = case @type
    when :delete
      delete_document_format
    else
      default_document_format
    end

    document.to_xml
  end
  
  private
    
    # TODO: default_document_format & delete_document_format are very similar, refactor
    # TODO: Don't create an array for each field type, figure out if it's an array first
    #  and act accordingly

    def default_document_format
      Nokogiri::XML::Builder.new do |xml|
        xml.send("#{@type}_") {
          @data.each do |object|
            xml.doc_ {
              object.each do |field_name, field_value|
                next if field_value.to_s.empty?
                values = field_value.is_a?(Array) ? field_value : [field_value]
                values.each do |value|
                  next if value.to_s.empty?
                  xml.field_(value, :name => field_name)
                end
              end
            }
          end
        }
      end
    end
    
    def delete_document_format
      Nokogiri::XML::Builder.new do |xml|
        xml.send("#{@type}_") {
          @data.each do |object|
            object.each do |field_name, field_value|
              next if field_value.to_s.empty?
              values = field_value.is_a?(Array) ? field_value : [field_value]
              values.each do |value|
                next if value.to_s.empty?
                xml.send("#{field_name}_", value)
              end
            end
          end
        }
      end
    end
end