#!/usr/bin/env ruby

# Pandoc filter to allow interpolation of metadata fields
# into a document.  %{fields} will be replaced by the field's
# value, assuming it is of the type MetaInlines or MetaString.

require 'pandoc_object_filters'

PandocObjectFilters::Filter.filter do |type,value,format,meta|
  if type == 'Str'
    match = /%\{(.*)\}$/.match(value)

    if match
      field = match[1]
      result = meta[field]

      if result['t'] == 'MetaInlines'
        next PandocObjectFilters::Element.Span(['', ['interpolated'], [['field', field]]], result['c'])
      elsif result['t'] == 'MetaString'
        next PandocObjectFilters::Element.Str(result['c'])
      end
    end
  end
end
