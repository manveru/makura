module Makura
  module Plugin
    module Localize
      LOCALIZE_GET = '
def %s
  raise(ArgumentError, "No language set") unless language
  self["%s_#{language}"]
end'.strip

      LOCALIZE_SET = '
def %s=(data)
  raise(ArgumentError, "No language set") unless language
  self["%s_#{language}"] = data
end'.strip

      module SingletonMethods
        def localized(*keys)
          keys.each do |key|
            class_eval(LOCALIZE_GET % [key, key])
            class_eval(LOCALIZE_SET % [key, key])
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
