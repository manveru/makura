module Makura
  class Layout
    attr_accessor :design, :name, :map, :reduce

    PATH = [
      './couch',
      File.join(Makura::ROOT, '../couch')
    ]

    def initialize(name, design = nil)
      @name, @design = name, design
      @design[name] = self
      @map = @reduce = nil
      @options = {}
    end

    def load_proto_map(file_or_function, replace = {})
      return unless common_load(:proto_map, file_or_function)
      replace.each{|from, to| @proto_map.gsub!(/"\{\{#{from}\}\}"/, to) }
      @map = @proto_map
    end

    def load_proto_reduce(file_or_function, replace = {})
      return unless common_load(:proto_reduce, file_or_function)
      replace.each{|from, to| @proto_reduce.gsub!(/"\{\{#{from}\}\}"/, to) }
      @reduce = @proto_reduce
    end

    def load_map(file_or_function)
      common_load(:map, file_or_function)
    end

    def load_reduce(file_or_function)
      common_load(:reduce, file_or_function)
    end

    def common_load(type, file_or_function)
      return unless file_or_function

      if file_or_function =~ /function\(.*\)/
        function = file_or_function
      else
        parts = file_or_function.split('::')
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
      {:map => @map, :reduce => @reduce, :makura_options => @options}
    end
  end
end
