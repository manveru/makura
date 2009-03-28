require 'pp'
require 'uri'

begin
  require 'rubygems'
rescue LoadError
end

require 'rest_client'
require 'json'

module Makura
  ROOT = File.expand_path(File.dirname(__FILE__))
end

unless $LOAD_PATH.any?{|lp| File.expand_path(lp) == Makura::ROOT }
  $LOAD_PATH.unshift(Makura::ROOT)
end

require 'makura/version'
require 'makura/error'
require 'makura/http_methods'
require 'makura/server'
require 'makura/database'
require 'makura/uuid_cache'
require 'makura/model'
require 'makura/design'
require 'makura/layout'

module Makura
  CHARS = (48..128).map{|c| c.chr}.grep(/[[:alnum:]]/)
  MOD = CHARS.size

  module_function

  # From Rack
  def escape(s)
    s.to_s.gsub(/([^ a-zA-Z0-9_.-]+)/n) {
      '%'+$1.unpack('H2'*$1.size).join('%').upcase
    }.tr(' ', '+')
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

Sofa = Makura # be backwards compatible
