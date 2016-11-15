require "pandoc_object_filters"

module PandocObjectFilters
  module V1_17
    module Element
      class BaseElement < PandocObjectFilters::V1_16::Element::BaseElement
        def to_ast
          { "t" => element_name, "c" => PandocObjectFilters::Element.to_ast(contents) }
        end
      end
    end
  end
end
