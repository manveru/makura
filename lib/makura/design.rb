module Makura
  class Design
    attr_accessor :database, :name, :language
    attr_reader :layouts
    attr_reader :filters
    
    def initialize(name, database = nil)
      @name, @database = name, database
      @language = 'javascript'
      @layouts = {}
      @filters = {}
    end

    def save
      hash = to_hash
      doc = @database[hash['_id']]
      doc['views'] = hash['views']
      doc['filters'] = hash['filters']
      @database.save(doc)
    rescue Makura::Error::ResourceNotFound
      @database.save(to_hash)
    end

    def [](layout_name)
      @layouts[layout_name.to_s] || @filters[layout_name.to_s]
    end

    def []=(layout_name, layout)      
      @layouts[layout_name.to_s] = layout if layout.class == Layout
      @filters[layout_name.to_s] = layout if layout.class == Filter 
    end

    def to_hash
      views = {}
      filters = {}
      
      @layouts.each{|name, layout| views[name] = layout.to_hash }
      views.delete_if{|k,v| !(v[:map] || v['map']) }
      
      @filters.each{|name, filter| filters[name] = filter.to_hash[:script] }
      #filters.delete_if{|k,v| k != :script }

      {'language' => @language, '_id' => "_design/#{@name}", 'views' => views, 'filters' => filters}
    end
  end
end
