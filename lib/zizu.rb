#!/usr/bin/env ruby
require "github_api"
require "haml"
require "highline/import"
require "open-uri"
require "rack"
require "rgit"
require "thor"
require "tilt"
require "yaml"
require "zip/zip"

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

  USER        = "stephenhu"
  REPOSITORY  = "bootstrap-haml"
  EXCLUDES    = [ "layout.haml", "navbar.haml", "footer.haml" ]
  BOOTSTRAP   = "http://twitter.github.com/bootstrap/assets/bootstrap.zip"

  def self.fatal(msg)
    puts msg.red
    exit
  end

  def self.warning(msg)
    puts msg.yellow
  end

  def self.info(msg)
    puts msg
  end

  def self.success(msg)
    puts msg.green
  end

end

