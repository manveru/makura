module Makura
  module Plugin
    # Automatically store/retrieve values for different languages.
    # Useful especially if combined with the locale gem.
    #
    # Default language is 'en'.
    #
    # Usage:
    #
    #   class Page
    #     include Makura::Model
    #
    #     plugin :localize
    #     localized :title, :text
    #   end
    #
    #   page = Page.new
    #   page.title = 'english title'
    #   page.title # => 'english title'
    #
    #   page.language = 'de'
    #   page.title # => nil
    #   page.title = 'deutscher titel'
    #   page.title # => 'deutscher titel'
    #
    #   page.language = 'en'
    #   page.title # => 'english title'
    module Localize
      LOCALIZE_GET = '
def %key%
  raise(ArgumentError, "No language set") unless language
  self["%key%_#{language}"] || self["%key%_#{self.class.default_language}"]
end'.strip

      LOCALIZE_SET = '
def %key%=(data)
  raise(ArgumentError, "No language set") unless language
  self["%key%_#{language}"] = data
end'.strip

      module SingletonMethods
        def localized(*keys)
          keys.each do |key|
            key = key.to_s
            class_eval(LOCALIZE_GET.gsub('%key%', key))
            class_eval(LOCALIZE_SET.gsub('%key%', key))
          end
        end

        def default_language=(dl)
          @default_language = dl
        end

        def default_language
          @default_language ||= 'en'
        end
      end

      module InstanceMethods
        attr_writer :language

        def language
          @language || self.class.default_language
        end
      end
    end
  end
end
