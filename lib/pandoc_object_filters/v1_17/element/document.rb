require "pandoc_object_filters"

module PandocObjectFilters
  module V1_17
    module Element
      class Document < PandocObjectFilters::V1_17::Element::Base
        include PandocObjectFilters::V1_16::Element::Document::Behavior
        attr_reader :pandoc_api_version

        def initialize(ast)
          object = PandocObjectFilters::Element.to_object(ast)
          meta_object = PandocObjectFilters::Element.to_object(object["meta"])
          @meta = PandocObjectFilters::Element::Meta.new(meta_object)
          @contents = object["blocks"]
          @pandoc_api_version = object["pandoc-api-version"]
        end

        def to_ast
          {
            "blocks" => PandocObjectFilters::Element.to_ast(contents),
            "meta" => PandocObjectFilters::Element.to_ast(meta),
            "pandoc-api-version" => pandoc_api_version
          }
        end
      end
    end
  end
end
