#!/usr/bin/env ruby

require 'pandoc_object_filters'

class CommentFilter
  @incomment = false

  def comment(type, value, format, meta)
    if type == 'RawBlock'
      fmt = value[0]
      s = value[1]
      if fmt == 'html'
        if /<!-- BEGIN COMMENT -->/.match(s)
          @incomment = true
          return []
        elsif /<!-- END COMMENT -->/.match(s)
          @incomment = false
          return []
        end
      end
    end
    if @incomment
      # Supress anything in a comment
      return []
    end
  end
end

filter = CommentFilter.new

PandocObjectFilters::Filter.filter do |type,value,format,meta|
  filter.comment(type,value,format,meta)
end
