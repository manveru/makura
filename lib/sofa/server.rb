module Sofa
  class Server
    attr_accessor :uri

    def initialize(uri = 'http://localhost:5984')
      @uri = URI(uri.to_s)
      @uuids = UUIDCache.new(self)
    end

    def inspect
      @uri.inspect
    end

    # General queries

    def info
      get('/')
    end

    def restart
      post('/_restart')
    end

    def databases
      get('/_all_dbs')
    end

    def database(name)
      Database.new(self, name)
    end

    def next_uuid
      @uuids.next
    end

    # HTTP Methods

    def delete(path, params = {})
      request(:delete, path, params)
    end

    def get(path, params = {})
      request(:get, path, params)
    end

    def post(path, params = {})
      request(:post, path, params)
    end

    def put(path, params = {})
      request(:put, path, params)
    end

    # Helpers

    def request(method, path, params = {})
      keep_raw = params.delete(:raw)
      payload = params.delete(:payload)
      payload = payload.to_json if payload and not keep_raw
      headers = {}

      if content_type = params.delete('Content-Type')
        headers['Content-Type'] = content_type
      end

      uri = uri(path, params).to_s

      request = {:method => method,
        :url => uri,
        :payload => payload,
        :headers => headers}

      raw = RestClient::Request.execute(request)
      return raw if keep_raw
      json = JSON.parse(raw)
    rescue RestClient::RequestFailed => ex
      if body = ex.response.body
        json = JSON.parse(body)
        raise(RequestFailed, json.inspect)
      else
        raise(RequestFailed, ex.message)
      end
    end

    JSON_PARAMS = %w[key startkey endkey]

    def paramify(hash)
      hash.map{|k,v|
        k = k.to_s
        v = v.to_json if JSON_PARAMS.include?(k)
        "#{Rack::Utils.escape(k)}=#{Rack::Utils.escape(v)}"
      }.join('&')
    end

    def uri(path = '/', params = {})
      uri = @uri.dup
      uri.path = (path[0,1] == '/' ? path : "/#{path}").squeeze('/')
      uri.query = paramify(params) unless params.empty?
      uri
    end
  end
end
