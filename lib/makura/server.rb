module Makura
  class Server
    include HTTPMethods
    attr_accessor :uri, :cache_ttl, :cache_tries

    COUCHDB_URI = 'http://localhost:5984'
    CACHE_TTL = 5
    CACHE_TRIES = 2

    # Usage:
    #   server = Makura::Server.new
    #   #<URI::HTTP:0xb778ce38 URL:http://localhost:5984>
    #   server.info
    #   {"couchdb"=>"Welcome", "version"=>"0.9.0a718650-incubating"}

    def initialize(uri = COUCHDB_URI, cache_ttl = CACHE_TTL, cache_tries = CACHE_TRIES)
      @uri = URI(uri.to_s)
      @cache_ttl = cache_ttl
      @cache_tries = cache_tries
      @uuids = UUIDCache.new(self)
    end

    def inspect
      @uri.inspect
    end

    # General queries

    # Answers with general couchdb info, looks like:
    #
    # Usage:
    #   server.info
    #   # {'couchdb' => 'Welcome', 'version' => '0.9.0a718650-incubating'}
    def info
      get('/')
    end

    # Answers with configuration info.
    #
    # Usage:
    #   server.config
    #
    def config
      get('/_config')
    end

    # Issue restart of the CouchDB daemon.
    #
    # Usage:
    #   server.restart
    #   # {'ok' => true}
    def restart
      post('/_restart')
    end

    def active_tasks
      get('/_active_tasks')
    end

    # Usage:
    #   server.replicate(source: "foodb", target: "http://example.org/foodb")
    #
    # Optional Arguments:
    #   # Start continuous replication
    #   continuous: (default is false)
    #
    #   # Create the target database
    #   create_target: (default is false)
    #
    #   # Cancel existing replication
    #   cancel: (default is false)
    #
    #   # Use a filter function
    #   filter: (default is none)
    #
    #   # Pass query parameters to filter function
    #   query_params: {key: value} (default is none)
    #
    # Please note that when you want to cancel a replication, you have to pass
    # the exact same arguments that it was created with plus the :cancel argument.
    def replicate(args)
      post('/_replicate', :payload => args)
    end

    # Array of names of databases on the server
    #
    # Usage:
    #   server.databases
    #   # ["another", "blog", "makura-spec"]
    def databases
      get('/_all_dbs')
    end

    # Return new database instance using this server instance.
    #
    # Usage:
    #   foo = server.database('foo')
    #   # #<Makura::Database 'http://localhost:5984/foo'>
    #   server.databases
    #   # ["another", "blog", "foo", "makura-spec"]

    def database(name)
      Database.new(self, name)
    end

    # Answers with an uuid from the UUIDCache.
    #
    # Usage:
    #   server.next_uuid
    #   # "55fdca746fa5a5b56f5270875477a2cc"

    def next_uuid
      @uuids.next
    end

    def start_cache(namespace = 'makura', *servers)
      servers << 'localhost:11211' if servers.empty?
      @cache = MemCache.new(servers, :namespace => namespace, :multithread => true)
    end

    def stop_cache
      @cache = nil
    end

    def cached(request, ttl = cache_ttl, tries = cache_tries)
      key = request[:url]

      unless response = @cache.get(key)
        response = execute(request)
        @cache.add(key, response, ttl)
      end

      return response
    rescue MemCache::MemCacheError => error
      servers = @cache.servers.map{|s| "#{s.host}:#{s.port}"}
      start_cache(@cache.namespace, *servers)
      tries -= 1
      retry if tries > 0
      warn "[makura caching disabled] #{error.message}"
      @cache = nil
      execute(request)
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

      params.delete_if{|k,v| v.nil? }
      uri = uri(path, params).to_s

      request = {
        :method => method,
        :url => uri,
        :payload => payload,
        :headers => headers}

      if @cache and request[:method] == :get
        raw = cached(request)
      else
        raw = execute(request)
      end

      return raw if keep_raw
      json = JSON.parse(raw)
    rescue JSON::ParserError
      return raw
    rescue RestClient::RequestFailed => ex
      raise appropriate_error(ex)
    rescue RestClient::ServerBrokeConnection => ex
      raise Error::ServerBrokeConnection, request[:url], ex.backtrace
    rescue RestClient::ResourceNotFound => ex
      raise Error::ResourceNotFound, request[:url], ex.backtrace
    rescue Errno::ECONNREFUSED
      raise Error::ConnectionRefused, "Is CouchDB running at #{@uri}?"
    end

    def execute(request)
      RestClient::Request.execute(request)
    end

    def appropriate_error(exception)
      body = exception.response.body if exception.respond_to?(:response)
      backtrace = exception.backtrace

      raise(Error::RequestFailed, exception.message, backtrace) unless body
      raise(Error::RequestFailed, exception.message, backtrace) if body.empty?

      json = JSON.parse(body)
      error, reason = json['error'], json['reason']

      case error
      when 'bad_request'
        raise(Error::BadRequest, reason, backtrace)
      when 'authorization'
        raise(Error::Authorization, reason, backtrace)
      when 'not_found'
        raise(Error::NotFound, reason, backtrace)
      when 'file_exists'
        raise(Error::FileExists, reason, backtrace)
      when 'missing_rev'
        raise(Error::MissingRevision, reason, backtrace)
      when 'conflict'
        raise(Error::Conflict, reason, backtrace)
      else
        raise(Error::RequestFailed, json.inspect, backtrace)
      end
    end

    def uri(path = '/', params = {})
      uri = @uri.dup
      uri.path = (path[0,1] == '/' ? path : "/#{path}").squeeze('/')
      uri.query = Makura.paramify(params) unless params.empty?
      uri
    end
  end
end
