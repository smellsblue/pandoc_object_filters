# Copyright (c) On-Site, 2016
# Copyright (c) Tom Potts, 2015
# Inspired by Python code by John MacFarlane.
# See http://pandoc.org/scripting.html
# and https://github.com/jgm/pandocfilters
# for more information.

require "pandoc_object_filters/version"
require "json"

module PandocObjectFilters
  module Element
    def self.to_ast(object)
      if object.respond_to?(:to_ast)
        object.to_ast
      elsif object.kind_of?(Array)
        object.map { |x| to_ast(x) }
      elsif object.kind_of?(Hash)
        result = {}
        object.each { |key, value| result[key] = to_ast(value) }
        result
      else
        object
      end
    end

    def self.to_object(object)
      if object.kind_of?(Array)
        object.map { |x| to_object(x) }
      elsif object.kind_of?(Hash) && object.include?('t') && object.include?('c')
        raise "Unknown type: #{object['t']}" unless PandocObjectFilters::Element.const_defined?(object['t'])
        type = PandocObjectFilters::Element.const_get(object['t'])
        raise "Invalid type: #{object['t']}" unless type < PandocObjectFilters::Element::BaseElement
        type.new(to_object(object['c']))
      elsif object.kind_of?(Hash) && object.include?('unMeta')
        PandocObjectFilters::Element::Meta.new(to_object(object['unMeta']))
      elsif object.kind_of?(Hash)
        result = {}
        object.each { |key, value| result[key] = to_object(value) }
        result
      else
        object
      end
    end

    def self.walk(object, &block)
      PandocObjectFilters::Element::Walker.new(object, &block).walk
    end

    def self.walk!(object, &block)
      PandocObjectFilters::Element::Walker.new(object, &block).walk!
    end

    def self.filter(input = $stdin, output = $stdout, argv = ARGV, &block)
      PandocObjectFilters::Element::Filter.new(input, output, argv, &block).filter
    end

    def self.filter!(input = $stdin, output = $stdout, argv = ARGV, &block)
      PandocObjectFilters::Element::Filter.new(input, output, argv, &block).filter!
    end

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

    class Walker
      def initialize(object, &block)
        @object = object
        @block = block
      end

      def walk(object = @object)
        if object.kind_of?(Array)
          object.each do |item|
            if item.kind_of?(PandocObjectFilters::Element::BaseElement)
              @block.call(item)
            end

            walk(item)
          end
        elsif object.kind_of?(Hash)
          object.values.each do |value|
            walk(value)
          end
        elsif object.kind_of?(PandocObjectFilters::Element::Base)
          walk(object.contents)
        end

        object
      end

      def walk!(object = @object)
        if object.kind_of?(Array)
          result = []
          object.each do |item|
            if item.kind_of?(PandocObjectFilters::Element::BaseElement)
              res = @block.call(item)
              if !res
                result.push(walk!(item))
              elsif res.kind_of?(Array)
                res.each do |z|
                  result.push(walk!(z))
                end
              else
                result.push(walk!(res))
              end
            else
              result.push(walk!(item))
            end
          end
          return result
        elsif object.kind_of?(Hash)
          result = {}
          object.each do |key, value|
            result[key] = walk!(value)
          end
          return result
        elsif object.kind_of?(PandocObjectFilters::Element::Base)
          object.contents = walk!(object.contents)
          return object
        else
          return object
        end
      end
    end

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

    class BaseElement < PandocObjectFilters::Element::Base
      def to_ast
        { 't' => element_name, 'c' => PandocObjectFilters::Element.to_ast(contents) }
      end
    end

    module Enum
      def [](key)
        elements[key]
      end

      def []=(key, value)
        elements[key] = value
      end
    end

    module MetaValue
    end

    module Inline
    end

    module Block
    end

    class Document < PandocObjectFilters::Element::Base
      attr_reader :meta

      def initialize(ast)
        object = PandocObjectFilters::Element.to_object(ast)
        @meta = object[0]
        @contents = object[1]
      end

      def to_ast
        [meta.to_ast, PandocObjectFilters::Element.to_ast(contents)]
      end
    end

    class Meta < PandocObjectFilters::Element::Base
      include PandocObjectFilters::Element::Enum
      alias_method :elements, :contents

      def initialize(contents = {})
        super
      end

      def to_ast
        { 'unMeta' => PandocObjectFilters::Element.to_ast(contents) }
      end
    end

    class Attr < PandocObjectFilters::Element::Base
      contents_attr :identifier, 0
      contents_attr :classes, 1
      contents_attr :key_values, 2

      def self.build(options = {})
        id = options.fetch(:identifier, '')
        classes = options.fetch(:classes, [])
        key_values = options.fetch(:key_values, [])

        if key_values.kind_of?(Hash)
          key_values = key_values.to_a
        end

        new([id, classes, key_values])
      end

      def [](key)
        # NOTE: While this pseudo Hash implementations are inefficient, they
        # guarantee any changes to key_values will be honored, which would be
        # difficult if the key_values were cached in a Hash
        result = key_values.find { |pair| pair.first == key } || []
        result[1]
      end

      def []=(key, value)
        found = key_values.find { |pair| pair.first == key }

        if found
          found[1] = value
        else
          key_values << [key, value]
        end
      end

      def include?(key)
        !!key_values.find { |pair| pair.first == key }
      end
    end

    class Target < PandocObjectFilters::Element::Base
      contents_attr :url, 0
      contents_attr :title, 1
    end

    [ ['MetaMap',        :elements,                                        { include: [PandocObjectFilters::Element::MetaValue, PandocObjectFilters::Element::Enum] }],
      ['MetaList',       :elements,                                        { include: [PandocObjectFilters::Element::MetaValue, PandocObjectFilters::Element::Enum] }],
      ['MetaBool',       :value,                                           { include: [PandocObjectFilters::Element::MetaValue] }],
      ['MetaString',     :value,                                           { include: [PandocObjectFilters::Element::MetaValue] }],
      ['MetaInlines',    :elements,                                        { include: [PandocObjectFilters::Element::MetaValue, PandocObjectFilters::Element::Enum] }],
      ['MetaBlocks',     :elements,                                        { include: [PandocObjectFilters::Element::MetaValue, PandocObjectFilters::Element::Enum] }],
      ['Plain',          :elements,                                        { include: [PandocObjectFilters::Element::Block, PandocObjectFilters::Element::Enum] }],
      ['Para',           :elements,                                        { include: [PandocObjectFilters::Element::Block, PandocObjectFilters::Element::Enum] }],
      ['CodeBlock',      :attributes, :value,                              { include: [PandocObjectFilters::Element::Block], conversions: { attributes: PandocObjectFilters::Element::Attr } }],
      ['RawBlock',       :format, :value,                                  { include: [PandocObjectFilters::Element::Block] }],
      ['BlockQuote',     :elements,                                        { include: [PandocObjectFilters::Element::Block, PandocObjectFilters::Element::Enum] }],
      ['OrderedList',    :attributes, :elements,                           { include: [PandocObjectFilters::Element::Block, PandocObjectFilters::Element::Enum] }],
      ['BulletList',     :elements,                                        { include: [PandocObjectFilters::Element::Block, PandocObjectFilters::Element::Enum] }],
      ['DefinitionList', :elements,                                        { include: [PandocObjectFilters::Element::Block, PandocObjectFilters::Element::Enum] }],
      ['Header',         :level, :attributes, :elements,                   { include: [PandocObjectFilters::Element::Block, PandocObjectFilters::Element::Enum], conversions: { attributes: PandocObjectFilters::Element::Attr } }],
      ['HorizontalRule',                                                   { include: [PandocObjectFilters::Element::Block] }],
      ['Table',          :captions, :alignments, :widths, :headers, :rows, { include: [PandocObjectFilters::Element::Block] }],
      ['Div',            :attributes, :elements,                           { include: [PandocObjectFilters::Element::Block, PandocObjectFilters::Element::Enum], conversions: { attributes: PandocObjectFilters::Element::Attr } }],
      ['Null',                                                             { include: [PandocObjectFilters::Element::Block] }],
      ['Str',            :value,                                           { include: [PandocObjectFilters::Element::Inline] }],
      ['Emph',           :elements,                                        { include: [PandocObjectFilters::Element::Inline, PandocObjectFilters::Element::Enum] }],
      ['Strong',         :elements,                                        { include: [PandocObjectFilters::Element::Inline, PandocObjectFilters::Element::Enum] }],
      ['Strikeout',      :elements,                                        { include: [PandocObjectFilters::Element::Inline, PandocObjectFilters::Element::Enum] }],
      ['Superscript',    :elements,                                        { include: [PandocObjectFilters::Element::Inline, PandocObjectFilters::Element::Enum] }],
      ['Subscript',      :elements,                                        { include: [PandocObjectFilters::Element::Inline, PandocObjectFilters::Element::Enum] }],
      ['SmallCaps',      :elements,                                        { include: [PandocObjectFilters::Element::Inline, PandocObjectFilters::Element::Enum] }],
      ['Quoted',         :type, :elements,                                 { include: [PandocObjectFilters::Element::Inline, PandocObjectFilters::Element::Enum] }],
      ['Cite',           :citations, :elements,                            { include: [PandocObjectFilters::Element::Inline, PandocObjectFilters::Element::Enum] }],
      ['Code',           :attributes, :value,                              { include: [PandocObjectFilters::Element::Inline], conversions: { attributes: PandocObjectFilters::Element::Attr } }],
      ['Space',                                                            { include: [PandocObjectFilters::Element::Inline] }],
      ['SoftBreak',                                                        { include: [PandocObjectFilters::Element::Inline] }],
      ['LineBreak',                                                        { include: [PandocObjectFilters::Element::Inline] }],
      ['Math',           :type, :value,                                    { include: [PandocObjectFilters::Element::Inline] }],
      ['RawInline',      :format, :value,                                  { include: [PandocObjectFilters::Element::Inline] }],
      ['Link',           :attributes, :elements, :target,                  { include: [PandocObjectFilters::Element::Inline, PandocObjectFilters::Element::Enum], conversions: { attributes: PandocObjectFilters::Element::Attr, target: PandocObjectFilters::Element::Target } }],
      ['Image',          :attributes, :elements, :target,                  { include: [PandocObjectFilters::Element::Inline, PandocObjectFilters::Element::Enum], conversions: { attributes: PandocObjectFilters::Element::Attr, target: PandocObjectFilters::Element::Target } }],
      ['Note',           :elements,                                        { include: [PandocObjectFilters::Element::Inline, PandocObjectFilters::Element::Enum] }],
      ['Span',           :attributes, :elements,                           { include: [PandocObjectFilters::Element::Inline, PandocObjectFilters::Element::Enum], conversions: { attributes: PandocObjectFilters::Element::Attr } }]
    ].each do |name, *params|
      name.freeze

      options = if params.last.kind_of?(Hash)
        params.pop
      else
        {}
      end

      case params.size
      when 0
        define_singleton_method(name) { {'t'=>name, 'c'=>[]} }
      when 1
        define_singleton_method(name) { |value| {'t'=>name, 'c'=>value} }
      when 2
        define_singleton_method(name) { |v1,v2| {'t'=>name, 'c'=>[v1,v2]} }
      when 3
        define_singleton_method(name) { |v1,v2,v3| {'t'=>name, 'c'=>[v1,v2,v3]} }
      when 4
        define_singleton_method(name) { |v1,v2,v3,v4| {'t'=>name, 'c'=>[v1,v2,v3,v4]} }
      when 5
        define_singleton_method(name) { |v1,v2,v3,v4,v5| {'t'=>name, 'c'=>[v1,v2,v3i,v4,v5]} }
      else
        raise "Too many parameters!"
      end

      const_set(name, Class.new(PandocObjectFilters::Element::BaseElement) {
        (options[:include] || []).each { |mod| include mod }

        if params.size == 1
          contents_attr params.first
        else
          params.each_with_index { |param, index| contents_attr param, index }
        end

        define_method(:element_name) { name }

        if options[:conversions]
          private

          define_method(:convert_contents) do
            @contents = @contents.map.with_index do |x, index|
              convert_to_type = options[:conversions][params[index]]

              if convert_to_type && !x.kind_of?(convert_to_type)
                convert_to_type.new(x)
              else
                x
              end
            end
          end
        end
      })
    end
  end
end
