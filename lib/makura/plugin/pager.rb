module Makura
  module Plugin
    module Pager
      module SingletonMethods
        def pager(page, limit)
          Makura::Plugin::Pager::Pagination.new(self, :pager, page, limit)
        end
      end

      class Pagination
        def initialize(model, view, page, limit)
          @model, @view, @page, @limit = model, view, page, limit
        end

        # /pager/_all_docs?count=10&group=true
        # /pager/_all_docs?startkey=%224f9dca1c66121f9320a69553546db07a%22&startkey_docid=4f9dca1c66121f9320a69553546db07a&skip=1&descending=false&count=10&group=true
        # /pager/_all_docs?startkey=%22_design%2FUser%22&startkey_docid=_design%2FUser&skip=1&descending=false&count=10&group=true
        # /pager/_all_docs?startkey=%22d850f0801686b85035680bb6f38d5c5c%22&startkey_docid=d850f0801686b85035680bb6f38d5c5c&skip=1&descending=false&count=10&group=true

        # NOTE:
        #   * descending should be true if you page backwards

        include Enumerable

        def each(start_id = nil, descending = false, &block)
          opts = {
            :count => @limit,
            :group => true,
            :descending => descending,
            # :include_docs => true,
          }

          if start_id
            opts[:skip] = 1
            opts[:startkey_docid] = start_id
            opts[:startkey] = start_id
          end

          @model.view(@view, opts).each(&block)
        end

        def count
        end

        def first_page?
        end

        def last_page?
        end

        def empty?
        end
      end
    end
  end
end
