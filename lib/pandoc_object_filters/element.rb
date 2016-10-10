require "pandoc_object_filters"

module PandocObjectFilters
  module Element
    autoload :Attr,        "pandoc_object_filters/element/attr"
    autoload :Base,        "pandoc_object_filters/element/base"
    autoload :BaseElement, "pandoc_object_filters/element/base_element"
    autoload :Block,       "pandoc_object_filters/element/block"
    autoload :Document,    "pandoc_object_filters/element/document"
    autoload :Enum,        "pandoc_object_filters/element/enum"
    autoload :Inline,      "pandoc_object_filters/element/inline"
    autoload :Meta,        "pandoc_object_filters/element/meta"
    autoload :MetaValue,   "pandoc_object_filters/element/meta_value"
    autoload :Target,      "pandoc_object_filters/element/target"

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
      PandocObjectFilters::Walker.new(object, &block).walk
    end

    def self.walk!(object, &block)
      PandocObjectFilters::Walker.new(object, &block).walk!
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
