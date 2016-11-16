require "pandoc_object_filters"

module PandocObjectFilters
  module V1_17
    module Element
      module Leaf
        def ==(other)
          self.class == other.class
        end

        def to_ast
          { "t" => element_name }
        end
      end
    end
  end
end
