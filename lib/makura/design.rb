module Makura
  class Design
    attr_accessor :database, :name, :language
    attr_reader :layouts

    def initialize(name, database = nil)
      @name, @database = name, database
      @language = 'javascript'
      @layouts = {}
    end

    def save
      hash = to_hash
      doc = @database[hash['_id']]
      doc['views'] = hash['views']
      @database.save(doc)
    rescue Makura::Error::ResourceNotFound
      @database.save(to_hash)
    end

    def [](layout_name)
      @layouts[layout_name.to_s]
    end

    def []=(layout_name, layout)
      @layouts[layout_name.to_s] = layout
    end

    def to_hash
      views = {}
      @layouts.each{|name, layout| views[name] = layout.to_hash }
      views.delete_if{|k,v| !(v[:map] || v['map']) }

      {'language' => @language, '_id' => "_design/#{@name}", 'views' => views}
    end
  end
end
