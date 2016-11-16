require "pandoc_object_filters"

module PandocObjectFilters
  module V1_17
    module Element
      class BaseElement < PandocObjectFilters::V1_17::Element::Base
        include PandocObjectFilters::V1_16::Element::BaseElement::Behavior
      end
    end
  end
end
