#!/usr/bin/env ruby
require "github_api"
require "haml"
require "highline/import"
require "rgit"
require "thor"
require "tilt"
require "yaml"

require File.join( File.dirname(__FILE__), "zizu", "githublib" )
require File.join( File.dirname(__FILE__), "zizu", "version" )
require File.join( File.dirname(__FILE__), "zizu", "cli" )

def haml(file)
  return Tilt.new("#{file}.haml").render
end

def url(location)
  # TODO add some logic to filter the url address
  return location
end

module Zizu

end

