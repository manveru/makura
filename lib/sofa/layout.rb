module Sofa
  class Layout
    attr_accessor :design, :name, :map, :reduce

    def initialize(name, design = nil)
      @name, @design = name, design
      @design[name] = self
      @map = @reduce = nil
      @options = {}
    end

    def load_map(file_or_function)
      common_load(:map, file_or_function)
    end

    def load_reduce(file_or_function)
      common_load(:reduce, file_or_function)
    end

    def common_load(root, file_or_function)
      return unless file_or_function

      if file_or_function =~ /function\(.*\)/
        function = file_or_function
      else
        filename = "couch/#{root}/#{file_or_function}.js"
        function = File.read(filename) if File.file?(filename)
      end

      instance_variable_set("@#{root}", function) if function
    end

    def save
      @design[@name] = self.to_hash
      @design.save
    end

    def to_hash
      {:map => @map, :reduce => @reduce, :sofa_options => @options}
    end
  end
end
