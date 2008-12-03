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

require 'sofa/error'
require 'sofa/http_methods'
require 'sofa/server'
require 'sofa/database'
require 'sofa/uuid_cache'
require 'sofa/model'
require 'sofa/design'
require 'sofa/layout'

module Sofa
  VERSION = '2008.12.03'

  def self.escape(*args)
    Rack::Utils.escape(*args)
  end
end
