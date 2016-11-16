require "pandoc_object_filters"

module PandocObjectFilters
  module V1_16
    module Element
      class Target < PandocObjectFilters::V1_16::Element::Base
        module Behavior
          def self.included(other)
            other.contents_attr :url, 0
            other.contents_attr :title, 1
          end
        end

        include Behavior
      end
    end
  end
end
