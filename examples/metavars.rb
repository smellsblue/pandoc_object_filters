#!/usr/bin/env ruby

# Pandoc filter to allow interpolation of metadata fields
# into a document.  %{fields} will be replaced by the field's
# value, assuming it is of the type MetaInlines or MetaString.

require "pandoc_object_filters"

filter = PandocObjectFilters::Filter.new

filter.filter! do |element|
  if element.is_a?(PandocObjectFilters::Element::Str)
    match = /%\{(.*)\}$/.match(element.value)

    if match
      field = match[1]
      result = filter.meta[field]

      if result.is_a?(PandocObjectFilters::Element::MetaInlines)
        attr = PandocObjectFilters::Element::Attr.build(classes: ["interpolated"], key_values: { "field" => field })
        next PandocObjectFilters::Element::Span.new([attr, result.elements])
      elsif result.is_a?(PandocObjectFilters::Element::MetaString)
        next PandocObjectFilters::Element::Str.new(result.value)
      end
    end
  end
end
