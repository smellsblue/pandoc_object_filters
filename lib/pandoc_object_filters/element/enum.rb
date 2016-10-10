require "pandoc_object_filters"

module PandocObjectFilters
  module Element
    module Enum
      def [](key)
        elements[key]
      end

      def []=(key, value)
        elements[key] = value
      end
    end
  end
end
