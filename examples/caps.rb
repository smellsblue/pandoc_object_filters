#!/usr/bin/env ruby

require 'pandoc_object_filters'

# Pandoc filter to convert all regular text to uppercase.
# Code, link URLs, etc. are not affected.

PandocObjectFilters::Filter.filter do |type, value, format, meta|
  if type == 'Str'
    PandocObjectFilters::Element.Str(value.upcase)
  end
end
