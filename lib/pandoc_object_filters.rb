# Copyright (c) On-Site, 2016
# Copyright (c) Tom Potts, 2015
# Inspired by Python code by John MacFarlane.
# See http://pandoc.org/scripting.html
# and https://github.com/jgm/pandocfilters
# for more information.
require "open3"

module PandocObjectFilters
  # NOTE: The version refers to the pandoc-types version, not the pandoc version
  autoload :V1_16, "pandoc_object_filters/v1_16"
  autoload :V1_17, "pandoc_object_filters/v1_17"

  autoload :ElementHelper, "pandoc_object_filters/element_helper"
  autoload :Filter,        "pandoc_object_filters/filter"
  autoload :VERSION,       "pandoc_object_filters/version"
  autoload :Walker,        "pandoc_object_filters/walker"

  def self.current_pandoc_version
    @current_pandoc_version ||=
      begin
        result, status = Open3.capture2(ENV.fetch("PANDOC_EXE", "pandoc"), "-v")

        unless status.success?
          raise "Cannot determine Pandoc version! " \
                "You may point to a valid Pandoc binary via a PANDOC_EXE environment variable."
        end

        type_version = result[/pandoc-types (\d+\.\d+)(?:\.\d+)*/, 1]
        type_version = type_version.to_f if type_version

        unless type_version
          version = result[/pandoc (\d+\.\d+)(?:\.\d+)*/, 1]
          version = version.to_f if version

          if version < 1.16
            raise "Pandoc is too old for pandoc_object_filters: #{version}"
          elsif version < 1.18
            type_version = 1.16
          elsif version < 1.19
            type_version = 1.17
          else
            raise "Pandoc is too new for this version of pandoc_object_filters: #{version}"
          end
        end

        if type_version < 1.16
          raise "Pandoc types is too old for pandoc_object_filters: #{version}"
        elsif type_version < 1.17
          PandocObjectFilters::V1_16
        elsif type_version < 1.18
          PandocObjectFilters::V1_17
        else
          raise "Pandoc types is too new for this version of pandoc_object_filters: #{version}"
        end
      end
  end

  Element = current_pandoc_version::Element

  def self.filter(input = $stdin, output = $stdout, argv = ARGV, &block)
    PandocObjectFilters::Filter.new(input, output, argv, &block).filter
  end

  def self.filter!(input = $stdin, output = $stdout, argv = ARGV, &block)
    PandocObjectFilters::Filter.new(input, output, argv, &block).filter!
  end
end
