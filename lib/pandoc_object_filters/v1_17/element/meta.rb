require "pandoc_object_filters"

module PandocObjectFilters
  module V1_17
    module Element
      class Meta < PandocObjectFilters::V1_17::Element::Base
        include PandocObjectFilters::V1_17::Element::Enum
        alias elements contents

        def initialize(contents = {})
          super
        end

        def to_ast
          PandocObjectFilters::Element.to_ast(contents)
        end
      end
    end
  end
end
