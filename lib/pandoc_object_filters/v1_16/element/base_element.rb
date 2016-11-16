require "pandoc_object_filters"

module PandocObjectFilters
  module V1_16
    module Element
      class BaseElement < PandocObjectFilters::V1_16::Element::Base
        module Behavior
          def to_ast
            { "t" => element_name, "c" => PandocObjectFilters::Element.to_ast(contents) }
          end
        end

        include Behavior
      end
    end
  end
end
