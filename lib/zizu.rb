#!/usr/bin/env ruby
require "github_api"
require "haml"
require "highline/import"
require "thor"
require "tilt"
require "yaml"

require File.join( File.dirname(__FILE__), "zizu", "cli" )
require File.join( File.dirname(__FILE__), "zizu", "version" )

def haml(file)
  return Tilt.new("#{file}.haml").render
end

def url(location)
  # TODO add some logic to filter the url address
  return location
end

module Zizu

end

