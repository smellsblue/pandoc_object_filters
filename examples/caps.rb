#!/usr/bin/env ruby

require "pandoc_object_filters"

# Pandoc filter to convert all regular text to uppercase.
# Code, link URLs, etc. are not affected.

PandocObjectFilters.filter do |element|
  element.value.upcase! if element.is_a?(PandocObjectFilters::Element::Str)
end
