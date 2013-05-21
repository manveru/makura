module Makura
  class Design
    attr_accessor :database, :name, :language
    attr_reader :layouts
    attr_reader :filters
    attr_reader :lists
    
    def initialize(name, database = nil)
      @name, @database = name, database
      @language = 'javascript'
      @layouts = {}
      @filters = {}
      @lists = {}
    end

    def save
      hash = to_hash
      doc = @database[hash['_id']]
      doc['views'] = hash['views']
      doc['filters'] = hash['filters']
      doc['lists'] = hash['lists']
      @database.save(doc)
    rescue Makura::Error::ResourceNotFound
      @database.save(to_hash)
    end

    def [](layout_name)
      @layouts[layout_name.to_s] || @filters[layout_name.to_s]  || @lists[layout_name.to_s]
    end

    def []=(layout_name, layout)      
      @layouts[layout_name.to_s] = layout if layout.class == Layout
      @filters[layout_name.to_s] = layout if layout.class == Filter
      @lists[layout_name.to_s] = layout if layout.class == List
    end

    def to_hash
      views = {}
      filters = {}
      lists = {}
      
      @layouts.each{|name, layout| views[name] = layout.to_hash }
      views.delete_if{|k,v| !(v[:map] || v['map']) }
      
      @filters.each{|name, filter| filters[name] = filter.to_hash[:script] }

      @lists.each{|name, list| lists[name] = list.to_hash[:script] }
      #filters.delete_if{|k,v| k != :script }

      {'language' => @language, '_id' => "_design/#{@name}", 'views' => views, 'filters' => filters, 'lists' => lists}
    end
  end
end
