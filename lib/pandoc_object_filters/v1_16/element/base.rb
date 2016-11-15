require "pandoc_object_filters"

module PandocObjectFilters
  module V1_16
    module Element
      class Base
        attr_accessor :contents

        def self.contents_attr(name, index = nil)
          if index
            define_method(name) { contents[index] }
            define_method("#{name}=") { |value| contents[index] = value }
          else
            define_method(name) { contents }
            define_method("#{name}=") { |value| @contents = value }
          end
        end

        def initialize(contents = [])
          @contents = contents
          convert_contents if respond_to?(:convert_contents, true)
        end

        def to_ast
          PandocObjectFilters::Element.to_ast(contents)
        end

        def inspect
          to_ast.inspect
        end

        def ==(other)
          self.class == other.class && contents == other.contents
        end

        def walk(&block)
          PandocObjectFilters::Element.walk(self, &block)
        end

        def walk!(&block)
          PandocObjectFilters::Element.walk!(self, &block)
        end
      end
    end
  end
end
