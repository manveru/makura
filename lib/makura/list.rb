module Makura
  class List
    attr_accessor :design, :name, :script
    
    PATH = [
      './couch',
      File.join(Makura::ROOT, '../couch')
    ]
    
    def initialize(name,design)
      @name = name
      @design = design
      @design[name] = self      
      @options = {}  
    end
    
    def load_proto_list(file_or_function, replace = {})
      return unless common_load(:proto_script, file_or_function)
      replace.each{|from, to| @proto_script.gsub!(/"\{\{#{from}\}\}"/, to) }
      @map = @proto_script
    end
    
    def load_list(file_or_function)
      common_load(:list, file_or_function)
    end
    
    def common_load(type, file_or_function)
      return unless file_or_function

      case file_or_function
      when /function\(.*\)/, /^_(sum|count|stats)$/
        function = file_or_function
      else
        parts = file_or_function.to_s.split('::')
        file = parts.pop
        filename = File.join(parts, type.to_s, "#{file}.js")
        
        if pathname = PATH.find{|pa| File.file?(File.join(pa, filename)) }
          function = File.read(File.join(pathname, filename))
        end
      end

      instance_variable_set("@#{type}", function) if function
    end
    
    def save
      @design[@name] = self.to_hash
      @design.save
    end
    
    def to_hash
      {:script => @list, :makura_options => @options}
    end
    
  end
end