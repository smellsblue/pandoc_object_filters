require "pandoc_object_filters"

module PandocObjectFilters
  module Element
    class Meta < PandocObjectFilters::Element::Base
      include PandocObjectFilters::Element::Enum
      alias elements contents

      def initialize(contents = {})
        super
      end

      def to_ast
        { "unMeta" => PandocObjectFilters::Element.to_ast(contents) }
      end
    end
  end
end
