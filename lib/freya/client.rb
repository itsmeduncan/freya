class Freya::Client
  attr_accessor :configuration
  attr_reader :master_connections, :slave_connections
  
  delegate :ping, :ping?, :valid?, :to => :master

  def initialize configuration
    @configuration = configuration

    @master_connections = connections_from_config("master")
    @slave_connections  = connections_from_config("slave")
  end
  
  # Return the next master connection from the available connections
  def master
    cycle @master_connections
  end

  # Return the next slave connection from the available connections if there
  # are available slaves. Otherwise, return the next available master
  # connection.
  def slave
    unless @slave_connections.empty?
      cycle @slave_connections
    else
      master
    end
  end
  
  # Select from the slave connections
  def find params
    slave.select params
  end
  
  # Add data to the master connection
  #
  # * Aliases update
  def add data
    master.update :add, data
  end
  alias_method :update, :add
  
  # Commit to the master connection
  def commit
    master.update :commit
  end
  
  # Delete from the master connection
  def delete params
    master.update :delete, params
  end
  
  # Delete by query from the master connection
  def delete_by_query query
    delete :query => query
  end
  
  # Delete by ID from the master connection
  def delete_by_id id
    delete :id => id
  end
  
  # Find and return the count from the slave connection
  def count params
    find(params.merge(:per_page => 0))["response"]["numFound"].to_i
  rescue Exception => e
    Freya.logger.error "Freya failed to #count! #{e}"
    0
  end
  
  # Optimize the master connection
  def optimize
    master.update :optimize
  end
  
  private
  
    # Return the next connection, and move it to the end of the group.
    def cycle connections
      return connections.first unless connections.length > 1
      
      connection = connections.shift
      connections << connection

      connection
    end

    # Create the Freya::Connections with proper Freya::Configurations for
    # the given type
    def connections_from_config(type)
      validate_configuration!

      (@configuration[type] || []).collect do |config|
        Freya::Connection.new(Freya::Configuration.new(config.merge("type" => type)))
      end
    end
    
    # Raise ArgumentError unless there is a master type
    def validate_configuration!
      raise ArgumentError.new("Configuration is missing :master type") unless @configuration.key?("master")
    end
end
