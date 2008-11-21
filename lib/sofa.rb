require 'pp'
require 'uri'

begin
  require 'rubygems'
rescue LoadError
end

require 'not_naughty'
require 'rest_client'
require 'rack'
require 'json'

NotNaughty::Validation.load(:presence, :length, :format)

$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'sofa/server'
require 'sofa/database'
require 'sofa/uuid_cache'
require 'sofa/model'
require 'sofa/design'
require 'sofa/layout'

module Sofa
  class Exception < ::RuntimeError; end
  class RequestFailed < Exception; end

  def self.escape(*args)
    Rack::Utils.escape(*args)
  end
end
