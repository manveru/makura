module Sofa
  module Model
    KEY = 'sofa_type'

    class << self
      attr_reader :server, :database

      def database=(name)
        @database = server.database(name)
      end

      def server=(obj)
        case obj
        when Sofa::Server
          @server = obj
        when String, URI
          @server = Sofa::Server.new(uri)
        else
          raise ArgumentError
        end
      end

      def server
        return @server if @server
        self.server = Sofa::Server.new
      end

      def included(into)
        into.extend(SingletonMethods, NotNaughty)
        into.send(:include, InstanceMethods)
        into.sofa_relation = {:belongs_to => {}, :has_many => {}}
        into.defaults = {'type' => into.name}
        into.properties(:_id, :_rev, :type)
      end
    end

    module InstanceMethods
      def initialize(hash = {})
        @_hash = self.class.defaults.dup
        merge!(hash)
      end

      def merge!(hash)
        case hash
        when Sofa::Model
          merge!(hash.to_hash)
#           relation = self.class.sofa_relation
#           pp self
#           pp relation
#           pp hash
        when Hash
          hash.each{|key, value|
            meth = "#{key}="

            if respond_to?(meth)
              self.send("#{key}=", value)
            else
              self[key.to_s] = value
            end
          }
        else
          raise ArgumentError, "This is neither relation data nor an Hash"
        end
      end

      def [](key)
        @_hash[key.to_s]
      end

      def []=(key, value)
        @_hash[key.to_s] = value
      end

      def to_hash
        @_hash.dup
      end

      def inspect
        "#<#{self.class} #{@_hash.inspect}>"
      end

      def pretty_print(o)
        ["#<#{self.class} ", @_hash, ">"].each{|e| e.pretty_print(o) }
      end

      def saved?
        self['_rev']
      end

      def save
        return if not valid? or saved?
        save!
      end

      def save!
        hash = self.to_hash

        self.class.sofa_relation.each do |kind, relation_hash|
          relation_hash.each do |key, value|
            hash[key.to_s] = hash[key.to_s] #._id
          end
        end

        response = self.class.database.save(hash)
        self._rev = response['rev']
        self._id = response['id']

        return self
      end

#         path, file, args = {})
      def attach(*args)
        self.class.database.put_attachment(self, *args)
      end

      def destroy
        self.class.database.delete(_id, :rev => _rev)
      end

      def ==(obj)
        self.class == obj.class and self._id == obj._id
      end
    end

    module SingletonMethods
      attr_accessor :defaults, :sofa_relation

      def database=(name)
        @database = Sofa::Model.server.database(name)
      end

      def database
        @database || Sofa::Model.database
      end

      def properties(*names)
        names.each{|name| property(name) }
      end

      def property(name, opts = {})
        name = name.to_s
        defaults[name] = opts.delete(:default) if opts[:default]

        class_eval("
          def #{name}() @_hash[#{name.dump}] end
          def #{name}=(obj) @_hash[#{name.dump}] = obj end")
      end

      def id(name)
        @id = name
        class_eval("
          alias #{name} _id
          alias #{name}= _id=")
      end

      def belongs_to(name, model = nil)
        name = name.to_s
        klass = (model || name.capitalize).to_s
        @sofa_relation[:belongs_to][name] = klass

        class_eval("
          def #{name}() #{klass}[self[#{name.dump}]] end
          def #{name}=(obj)
            if obj.respond_to?(:_id)
              @_hash[#{name.dump}] = obj._id
            else
              @_hash[#{name.dump}] = obj
            end
          end")
      end

      def has_many(name, model = nil)
        name = name.to_s
        klass = (model || name.capitalize).to_s
        @sofa_relation[:has_many][name] = klass

        class_eval("
          def #{name}() #{klass}[self[#{name.dump}]] end
          def #{name}=(obj)
            raise RuntimeError, 'You many not assign here'
          end")
      end

      def [](id, rev = nil)
        new(database[id, rev])
      rescue RestClient::ResourceNotFound
        nil
      end

      def design
        @design ||= Design.new(name.to_s, database)
      end

      def layout(name, opts = {})
        design[name] = layout = Layout.new(name, design)

        map_name = opts[:map] || "#{self.name}_#{name}".downcase
        layout.load_map(map_name)

        reduce_name = opts[:reduce] || "#{self.name}_#{name}".downcase
        layout.load_reduce(opts[:reduce])

        layout
      end

      def save
        design.save
      end

      def view(name, opts = {})
        hash = database.view("#{self}/#{name}", opts)
        pp hash

        hash['rows'].map! do |row|
          value = row['doc'] || row['value']

          if value.respond_to?(:to_hash)
            if type = value['type']
              const_get(type).new(value)
            else
              row
            end
          elsif not row['key']
            value
          else
            row
          end
        end
      end
    end
  end
end
