require 'cgi'
require 'will_paginate'
require 'net/http'
require 'logger'

$:.unshift(File.dirname(__FILE__))

module Freya

  autoload :Client, "freya/client"
  autoload :Connection, "freya/connection"
  autoload :Configuration, "freya/configuration"
  autoload :Document, "freya/document"
  autoload :QueryString, "freya/query_string"
  autoload :Response, "freya/response"
  autoload :Faceting, "freya/faceting/faceting"

  class << self
    mattr_accessor :logger

    def version
      @version ||= File.read(File.join(File.dirname(__FILE__), '..', 'VERSION')).chomp
    end

  end

  VERSION = self.version

  Freya.logger = Logger.new(STDOUT)

end