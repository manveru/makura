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
  CHARS = (48..128).map{|c| c.chr}.grep(/[[:alnum:]]/)
  MOD = CHARS.size

  module_function

  def escape(*args)
    Rack::Utils.escape(*args)
  end

  def pretty_from_md5(md5)
    id = md5.to_i(16)
    o = []
    while id > 0
      id, r = id.divmod(MOD)
      o.unshift CHARS[r]
    end
    o.join
  end

  def pretty_to_md5(id)
    i = 0
    id.scan(/./) do |c|
      i = i * MOD + CHARS.index(c)
    end
    i.to_s(16)
  end
end
