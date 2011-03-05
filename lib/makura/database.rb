module Makura
  class Database
    include HTTPMethods
    attr_accessor :server, :name

    # Initialize instance of Database and create if it doesn't exist yet.
    # To prevent automatic creation, pass false as 3rd parameter
    #
    # Usage:
    #   server = Makura::Server.new
    #   # #<URI::HTTP:0xb7788234 URL:http://localhost:5984>
    #   database = Makura::Database.new(server, 'foo')
    #   # #<Makura::Database 'http://localhost:5984/foo'>

    def initialize(server, name, auto_create = true)
      @server, @name = server, name
      create if auto_create
    end

    # Create the database if it doesn't exist already.
    #
    # Usage:
    #   server = Makura::Server.new
    #   # #<URI::HTTP:0xb76a4a98 URL:http://localhost:5984>
    #
    #   database = Makura::Database.new(server, 'foo', false)
    #   # #<Makura::Database 'http://localhost:5984/foo'>
    #
    #   database.create
    #   # {"update_seq"=>0, "doc_count"=>0, "purge_seq"=>0, "disk_size"=>4096,
    #   #  "compact_running"=>false, "db_name"=>"foo", "doc_del_count"=>0}

    def create
      info
    rescue Error::ResourceNotFound
      put("/", :payload => '')
    end

    # Will delete document in the CouchDB corresponding to given +doc+.
    # Use #destroy to delete the database itself.
    # Use #delete! to automatically rescue exceptions on conflicts.
    #
    # Possible variations (User is a Makura::Model) are:
    #
    #   # deleting based on explicit _id and :rev option.
    #   database.delete('manveru', :rev => 123134)
    #
    #   # deleting based on a Hash
    #   database.delete('_id' => 'manveru', '_rev' => 123134)
    #
    #   user = User.new(:name => 'manveru')
    #   user.save
    #   database.delete(user)
    #
    # Usage when deleting document:
    #   doc = database.save('name' => 'manveru', 'time' => Time.now)
    #   # {"rev"=>"484030692", "id"=>"67e086087d5b7e7196b5c99174b0b66c", "ok"=>true}
    #
    #   database[doc['id']]
    #   # {"name"=>"manveru", "_rev"=>"484030692",
    #      "time"=>"Sat Nov 22 16:37:50 +0900 2008",
    #      "_id"=>"67e086087d5b7e7196b5c99174b0b66c"}
    #
    #   database.delete(doc['id'], :rev => doc['rev'])
    #   # {"rev"=>"2034883605", "id"=>"67e086087d5b7e7196b5c99174b0b66c", "ok"=>true}
    #
    #   database[doc['id']]
    #   RestClient::ResourceNotFound: RestClient::ResourceNotFound
    #
    #   database.delete(doc['id'], :rev => doc['rev'])
    #   Makura::RequestFailed: {"reason"=>"Document update conflict.", "error"=>"conflict"}

    def delete(doc, opts = {})
      case doc
      when Makura::Model
        doc_id, doc_rev = doc._id, doc._rev
      when Hash
        doc_id  = doc['_id']  || doc['id']  || doc[:_id]  || doc[:id]
        doc_rev = doc['_rev'] || doc['rev'] || doc[:_rev] || doc[:rev]
      else
        doc_id = doc
      end

      raise(ArgumentError, "document _id wasn't passed") unless doc_id

      doc_id = Makura.escape(doc_id)
      opts[:rev] ||= doc_rev if doc_rev

      request(:delete, doc_id.to_s, opts)
    end

    def delete!(doc, opts = {})
      delete(doc, opts)
    rescue Error::Conflict, Error::ResourceNotFound
    end

    # Delete the database itself.
    #
    # Usage:
    #   database.destroy
    #   # {"ok"=>true}
    #   database.info
    #   # RestClient::ResourceNotFound: RestClient::ResourceNotFound

    def destroy(opts = {})
      request(:delete, '/', opts)
    end

    def destroy!(opts = {})
      destroy(opts)
    rescue Error::ResourceNotFound
    end

    def info
      get('/')
    end

    def compact(design_name = nil)
      if design_name
        post("/_compact/#{design_name}")
      else
        post("/_compact")
      end
    end

    def view_cleanup
      post("/_view_cleanup")
    end

    def ensure_full_commit
      post('/_ensure_full_commit')
    end

    def all_docs(params = {})
      get('_all_docs', params)
    end
    alias documents all_docs

    def [](id, rev = nil)
      id = Makura.escape(id)
      if rev
        get(id, :rev => rev)
      else
        get(id)
      end
    end

    def []=(id, doc)
      id = Makura.escape(id)
      put(id, :payload => prepare_doc(doc))
    end

    def temp_view(params = {})
      params[:payload] = functions = {}
      functions[:map] = params.delete(:map) if params[:map]
      functions[:reduce] = params.delete(:reduce) if params[:reduce]
      params['Content-Type'] = 'application/json'

      post('_temp_view', params)
    end

    def view(layout, params = {})
      get("_design/#{layout}", params)
    end

    def save(doc)
      if id = doc['_id']
        id = Makura.escape(id)
        put(id, :payload => prepare_doc(doc))
      else
        id = doc['_id'] = @server.next_uuid
        id = Makura.escape(id)
        put(id, :payload => prepare_doc(doc))
      end
    end

    # NOTE:
    #   * Seems like we don't even need to check _id, CouchDB will assign it.
    #     But in order to use our own uuids we still do it.
    def bulk_docs(docs)
      docs.each{|doc| doc['_id'] ||= @server.next_uuid }
      post("_bulk_docs", :payload => {:docs => docs}, 'Content-Type' => 'application/json')
    end
    alias bulk_save bulk_docs

    def get_attachment(doc, file_id)
      doc_id = doc.respond_to?(:_id) ? doc._id : doc.to_str
      file_id, doc_id = Makura.escape(file_id), Makura.escape(doc_id)

      get("#{doc_id}/#{file_id}", :raw => true)
    end

    # PUT an attachment directly to CouchDB
    def put_attachment(doc, file_id, file, options = {})
      doc_id, file_id = Makura.escape(doc._id), Makura.escape(file_id)

      options[:payload] = file
      options[:raw] = true
      options[:rev] = doc._rev if doc._rev

      put("#{doc_id}/#{file_id}", options)
    end

    def prepare_doc(doc)
      if attachments = doc['_attachments']
        doc['_attachments'] = encode_attachments(attachments)
      end

      return doc
    end

    def request(method, path, params = {})
      @server.send(:request, method, "/#{name}/#{path}", params)
    end

    def encode_attachments(attachments)
      attachments.each do |key, value|
        next if value['stub']
        value['data'] = base64(value['data'])
      end
      attachments
    end

    def base64(data)
      [data.to_s].pack('m').delete("\n")
    end

    def inspect
      "#<Makura::Database '#{@server.uri(name || '/')}'>"
    end
  end
end
