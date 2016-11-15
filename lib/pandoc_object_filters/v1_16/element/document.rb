require "pandoc_object_filters"

module PandocObjectFilters
  module V1_16
    module Element
      class Document < PandocObjectFilters::V1_16::Element::Base
        attr_reader :meta

        def initialize(ast)
          object = PandocObjectFilters::Element.to_object(ast)
          @meta = object[0]
          @contents = object[1]
        end

        def to_ast
          [meta.to_ast, PandocObjectFilters::Element.to_ast(contents)]
        end
      end
    end
  end
end
