# Copyright (c) On-Site, 2016
# Copyright (c) Tom Potts, 2015
# Inspired by Python code by John MacFarlane.
# See http://pandoc.org/scripting.html
# and https://github.com/jgm/pandocfilters
# for more information.
require "open3"

module PandocObjectFilters
  autoload :V1_16,   "pandoc_object_filters/v1_16"
  autoload :Filter,  "pandoc_object_filters/filter"
  autoload :VERSION, "pandoc_object_filters/version"
  autoload :Walker,  "pandoc_object_filters/walker"

  Element = PandocObjectFilters::V1_16::Element

  def self.filter(input = $stdin, output = $stdout, argv = ARGV, &block)
    PandocObjectFilters::Filter.new(input, output, argv, &block).filter
  end

  def self.filter!(input = $stdin, output = $stdout, argv = ARGV, &block)
    PandocObjectFilters::Filter.new(input, output, argv, &block).filter!
  end
end
