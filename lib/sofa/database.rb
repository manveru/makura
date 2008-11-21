module Sofa
  class Database
    attr_accessor :server, :name

    def initialize(server, name)
      @server, @name = server, name
      create
    end

    def create
      info
    rescue
      @server.put("/#{name}", :payload => '')
    end

    def delete(arg = nil, opts = {})
      if arg
        @server.delete("/#{name}/#{arg}", opts)
      else
        @server.delete("/#{name}", opts)
      end
    end

    def inspect
      "#<Sofa::Database '#{@server.uri(name)}'>"
    end

    def info
      @server.get(name)
    end

    def all_docs(params = {})
      @server.get("/#{name}/_all_docs")
    end
    alias documents all_docs

    def [](id, rev = nil)
      id = Sofa.escape(id)
      if rev
        @server.get("/#{name}/#{id}", :rev => rev)
      else
        @server.get("/#{name}/#{id}")
      end
    end

    def temp_view(params = {})
      params[:payload] = functions = {}
      functions[:map] = params.delete(:map) if params[:map]
      functions[:reduce] = params.delete(:reduce) if params[:reduce]
      params['Content-Type'] = 'application/json'

      @server.post("/#{name}/_temp_view", params)
    end

    def view(layout, params = {})
      @server.get("/#{name}/_view/#{layout}", params)
    end

    def save(doc)
      if id = doc['_id']
        id = Sofa.escape(id)
        @server.put("#{name}/#{id}", :payload => prepare_doc(doc))
      else
        id = doc['_id'] = @server.next_uuid
        id = Sofa.escape(id)
        @server.put("#{name}/#{id}", :payload => prepare_doc(doc))
      end
    end

    def get_attachment(doc, file_id)
      doc_id = doc.respond_to?(:_id) ? doc._id : doc.to_str
      file_id, doc_id = Sofa.escape(file_id), Sofa.escape(doc_id)

      @server.get("/#{name}/#{doc_id}/#{file_id}", :raw => true)
    end

    # PUT an attachment directly to CouchDB
    def put_attachment(doc, file_id, file, options = {})
      doc_id, file_id = Sofa.escape(doc._id), Sofa.escape(file_id)

      options[:payload] = file
      options[:raw] = true
      options[:rev] = doc._rev if doc._rev

      @server.put("/#{name}/#{doc_id}/#{file_id}", options)
    end

    def prepare_doc(doc)
      if attachments = doc['_attachments']
        doc['_attachments'] = encode_attachments(attachments)
      end

      return doc
    end
  end
end
