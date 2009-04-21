module Makura
  module Model
    KEY = 'makura_type'

    class << self
      attr_reader :server, :database

      def database=(name)
        @database = server.database(name)
      end

      def server=(obj)
        case obj
        when Makura::Server
          @server = obj
        when String, URI
          @server = Makura::Server.new(obj)
        else
          raise ArgumentError
        end
      end

      def server
        return @server if @server
        self.server = Makura::Server.new
      end

      def included(into)
        into.extend(SingletonMethods)
        into.send(:include, InstanceMethods)
        into.makura_relation = {:belongs_to => {}, :has_many => {}}
        into.property_type = {}
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
        when Makura::Model
          merge!(hash.to_hash)
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

      def to_json
        @_hash.to_json
      end

      def inspect
        "#<#{self.class} #{@_hash.inspect}>"
      end

      def pretty_print(o)
        ["#<#{self.class} ", @_hash, ">"].each{|e| e.pretty_print(o) }
      end

      def save
        return if not valid? if respond_to?(:valid)
        save!
      end

      def save!
        hash = self.to_hash

        self.class.makura_relation.each do |kind, relation_hash|
          relation_hash.each do |key, value|
            hash[key.to_s] = hash[key.to_s] #._id
          end
        end

        response = self.class.database.save(hash)
        self._rev = response['rev']
        self._id = response['id']

        return self
      end

      # path, file, args = {})
      def attach(*args)
        self.class.database.put_attachment(self, *args)
      end

      # delete attachment by name.
      # we make sure the parameter is given and a nonempty string to avoid
      # destroying the document itself
      def detach(name)
        name.strip!
        return if name.empty?
        self.class.database.request(:delete, "#{_id}/#{name}", :rev => _rev)
      rescue Makura::Error::Conflict
        self['_rev'] = self.class[self._id]['_rev']
        retry
      end

      def destroy
        self.class.database.delete(_id, :rev => _rev)
      end

      def ==(obj)
        self.class == obj.class and self._id == obj._id
      end

      def hash
        @_hash.hash
      end

      def eql?(other)
        other == self && other.hash == self.hash
      end

      def clone
        hash = @_hash.dup
        hash.delete('_id')
        hash.delete('_rev')
        self.class.new(hash)
      end
    end

    module SingletonMethods
      attr_accessor :defaults, :makura_relation, :property_type

      def plugin(name)
        require "makura/plugin/#{name}".downcase

        name = name.to_s.capitalize
        mod = Makura::Plugin.const_get(name)

        include(mod::InstanceMethods) if defined?(mod::InstanceMethods)
        extend(mod::SingletonMethods) if defined?(mod::SingletonMethods)
      end

      def database=(name)
        @database = Makura::Model.server.database(name)
      end

      def database
        @database || Makura::Model.database
      end

      def properties(*names)
        names.each{|name| property(name) }
      end

      def property(name, opts = {})
        name = name.to_s
        defaults[name] = default = opts.delete(:default) if opts[:default]
        property_type[name] = type = opts.delete(:type) if opts[:type]

        if type == Time
          code = "
            def #{name}()
              Time.at(@_hash[#{name.dump}].to_i)
            end
            def #{name}=(obj)
              @_hash[#{name.dump}] = obj.to_i
            end"
          class_eval(code)
        else
          code = "
            def #{name}() @_hash[#{name.dump}] end
            def #{name}=(obj) @_hash[#{name.dump}] = obj end"
        end

        class_eval(code)
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
        @makura_relation[:belongs_to][name] = klass

        class_eval("
          def #{name}()
            @#{name} ||= #{klass}[self[#{name.dump}]]
          end
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
        @makura_relation[:has_many][name] = klass

        class_eval("
          def #{name}()
            @#{name} ||= #{klass}[self[#{name.dump}]]
          end
          def #{name}=(obj)
            return unless obj
            raise RuntimeError, 'You many not assign here'
          end")
      end

      def [](id, rev = nil)
        new(database[id, rev])
      rescue Error::ResourceNotFound
        nil
      end

      def design
        @design ||= Design.new(name.to_s, database)
      end

      def layout(name, opts = {})
        design[name] = layout = Layout.new(name, design)
        unless opts[:map] or opts[:reduce]
          prefix = self.name.gsub(/\B[A-Z][^A-Z]/, '_\&')
        end

        map_name    = opts[:map]    || "#{prefix}_#{name}".downcase
        reduce_name = opts[:reduce] || "#{prefix}_#{name}".downcase

        layout.load_map(map_name)
        layout.load_reduce(reduce_name)

        return layout
      end

      def proto_layout(common, name, opts = {})
        design[name] = layout = Layout.new(name, design)

        map_name    = opts.delete(:map)    || "#{self.name}_#{common}".downcase
        reduce_name = opts.delete(:reduce) || "#{self.name}_#{common}".downcase

        layout.load_proto_map(map_name, opts)
        layout.load_proto_reduce(reduce_name, opts)

        return layout
      end

      def save
        design.save
      end

      # +opts+ must include a :keys or 'keys' key with something that responds
      # to #to_a as value
      #
      # Usage given a map named `Post/by_tags' that does something like:
      #
      #     for(t in doc.tags){ emit([doc.tags[t]], null); }
      #
      # You can use this like:
      #
      #     keys = ['ruby', 'couchdb']
      #     Post.multi_fetch(:by_tags, :keys => keys)
      #
      # And it will return all docs with the tags 'ruby' OR 'couchdb'
      # This can be extended to match even more complex things
      #
      #   for(t in doc.tags){ emit([doc.author, doc.tags[t]], null); }
      #
      # Now we do
      #
      #     keys = [['manveru', 'ruby'], ['mika', 'couchdb']]
      #     Post.multi_fetch(:by_tags, :keys => keys)
      #
      # This will return all docs match following:
      #     ((author == 'manveru' && tags.include?('ruby')) ||
      #      (author == 'mika' && tags.include?('couchdb')))
      #
      # Of course you can add as many keys as you like:
      #
      #     keys = [['manveru', 'ruby'],
      #             ['manveru', 'couchdb'],
      #             ['mika', 'design']]
      #             ['mika', 'couchdb']]
      #     Post.multi_fetch(:by_tags, :keys => keys)
      #
      #
      # From http://wiki.apache.org/couchdb/HTTP_view_API
      #   A JSON structure of {"keys": ["key1", "key2", ...]} can be posted to
      #   any user defined view or _all_docs to retrieve just the view rows
      #   matching that set of keys. Rows are returned in the order of the keys
      #   specified. Combining this feature with include_docs=true results in
      #   the so-called multi-document-fetch feature.

      def multi_fetch(name, opts = {})
        keys = opts.delete(:keys) || opts.delete('keys')
        opts.merge!(:payload => {'keys' => Array(keys)})
        hash = database.post("_view/#{self}/#{name}", opts)
        convert_raw(hash['rows'])
      end

      def multi_fetch_with_docs(name, opts = {})
        opts.merge!(:include_docs => true, :reduce => false)
        multi_fetch(name, opts)
      end
      alias multi_document_fetch multi_fetch_with_docs

      # It is generally recommended not to include the doc in the emit of the
      # map function but to use include_docs=true.
      # To make using this approach more convenient use this method.

      def view_with_docs(name, opts = {})
        opts.merge!(:include_docs => true, :reduce => false)
        view(name, opts)
      end

      alias view_docs view_with_docs

      def view(name, opts = {})
        flat = opts.delete(:flat)
        hash = database.view("#{self}/_view/#{name}", opts)

        convert_raw(hash['rows'], flat)
      end

      def convert_raw(rows, flat = false)
        rows.map do |row|
          value = row['doc'] || row['value']

          if value.respond_to?(:to_hash)
            if type = value['type'].split('::') and not flat
              model_class = type.inject(Object){ |ns, name| ns.const_get(name) }
              model_class.new(value)
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
