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
  JSON_PARAMS = %w[key startkey endkey]

  module_function

  # From Rack
  def escape(s)
    s.to_s.gsub(/([^ a-zA-Z0-9_.-]+)/u) {
      '%'+$1.unpack('H2'*bytesize($1)).join('%').upcase
    }.tr(' ', '+')
  end

  def paramify(hash)
    hash.map{|k,v|
      k = k.to_s
      v = v.to_json if JSON_PARAMS.include?(k)
      "#{escape(k)}=#{escape(v)}"
    }.join('&')
  end

  if "".respond_to?(:bytesize)
    def bytesize(string)
      string.bytesize
    end
  else
    def bytesize(string)
      string.size
    end
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

  def constant(name, root = Module)
    name.split('::').inject(root){|s,v| s.const_get(v) }
  end
end
