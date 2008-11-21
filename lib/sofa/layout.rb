module Sofa
  class Layout
    attr_accessor :design, :name, :map, :reduce

    def initialize(name, design = nil)
      @name, @design = name, design
      @design[name] = self
      @map = @reduce = nil
      @options = {}
    end

    def load_map(file)
      return unless file
      @map = File.read(File.join('couch/map', "#{file}.js"))
    end

    def load_reduce(file)
      return unless file
      @reduce = File.read(File.join('couch/reduce', "#{file}.js"))
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
