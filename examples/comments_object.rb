#!/usr/bin/env ruby

require 'pandoc_object_filters'

incomment = false

PandocObjectFilters::Element.filter! do |element|
  if element.kind_of?(PandocObjectFilters::Element::RawBlock)
    if element.format == 'html'
      if /<!-- BEGIN COMMENT -->/.match(element.value)
        incomment = true
        next []
      elsif /<!-- END COMMENT -->/.match(element.value)
        incomment = false
        next []
      end
    end
  end

  next [] if incomment
end
