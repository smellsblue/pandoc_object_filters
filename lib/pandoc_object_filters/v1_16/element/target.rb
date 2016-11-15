require "pandoc_object_filters"

module PandocObjectFilters
  module V1_16
    module Element
      class Target < PandocObjectFilters::Element::Base
        contents_attr :url, 0
        contents_attr :title, 1
      end
    end
  end
end
