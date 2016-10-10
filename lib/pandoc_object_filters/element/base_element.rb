require "pandoc_object_filters"

module PandocObjectFilters
  module Element
    class BaseElement < PandocObjectFilters::Element::Base
      def to_ast
        { "t" => element_name, "c" => PandocObjectFilters::Element.to_ast(contents) }
      end
    end
  end
end
