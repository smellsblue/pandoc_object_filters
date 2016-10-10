#!/usr/bin/env ruby

require 'pandoc_object_filters'

# Pandoc filter to convert all regular text to uppercase.
# Code, link URLs, etc. are not affected.

PandocObjectFilters::Element.filter do |element|
  if element.kind_of?(PandocObjectFilters::Element::Str)
    element.value.upcase!
  end
end
