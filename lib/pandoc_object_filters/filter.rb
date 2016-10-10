require "pandoc_object_filters"
require "json"

module PandocObjectFilters
  class Filter
    attr_accessor :doc, :format, :meta

    def initialize(input = $stdin, output = $stdout, argv = ARGV, &block)
      @input = input
      @output = output
      @argv = argv
      @block = block
    end

    def filter(&block)
      process(block) do
        PandocObjectFilters::Element.walk(@doc, &@block)
        @doc
      end
    end

    def filter!(&block)
      process(block) { PandocObjectFilters::Element.walk!(@doc, &@block) }
    end

    private

    def process(block)
      @block = block unless @block
      @doc = PandocObjectFilters::Element::Document.new(JSON.parse(@input.read))
      @format = @argv.first
      @meta = @doc.meta
      result = yield
      @output.puts JSON.dump(PandocObjectFilters::Element.to_ast(result))
    end
  end
end
