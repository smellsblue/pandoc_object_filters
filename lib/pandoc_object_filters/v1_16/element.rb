require "pandoc_object_filters"

module PandocObjectFilters
  module V1_16
    module Element
      autoload :Attr,        "pandoc_object_filters/v1_16/element/attr"
      autoload :Base,        "pandoc_object_filters/v1_16/element/base"
      autoload :BaseElement, "pandoc_object_filters/v1_16/element/base_element"
      autoload :Block,       "pandoc_object_filters/v1_16/element/block"
      autoload :Document,    "pandoc_object_filters/v1_16/element/document"
      autoload :Enum,        "pandoc_object_filters/v1_16/element/enum"
      autoload :Inline,      "pandoc_object_filters/v1_16/element/inline"
      autoload :Meta,        "pandoc_object_filters/v1_16/element/meta"
      autoload :MetaValue,   "pandoc_object_filters/v1_16/element/meta_value"
      autoload :Target,      "pandoc_object_filters/v1_16/element/target"

      def self.to_ast(object)
        if object.respond_to?(:to_ast)
          object.to_ast
        elsif object.is_a?(Array)
          object.map { |x| to_ast(x) }
        elsif object.is_a?(Hash)
          result = {}
          object.each { |key, value| result[key] = to_ast(value) }
          result
        else
          object
        end
      end

      def self.to_object(object)
        if object.is_a?(Array)
          object.map { |x| to_object(x) }
        elsif object.is_a?(Hash) && object.include?("t") && object.include?("c")
          raise "Unknown type: #{object['t']}" unless PandocObjectFilters::Element.const_defined?(object["t"])
          type = PandocObjectFilters::Element.const_get(object["t"])
          raise "Invalid type: #{object['t']}" unless type < PandocObjectFilters::Element::BaseElement
          type.new(to_object(object["c"]))
        elsif object.is_a?(Hash) && object.include?("unMeta")
          PandocObjectFilters::Element::Meta.new(to_object(object["unMeta"]))
        elsif object.is_a?(Hash)
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

      # rubocop:disable Metrics/LineLength
      [["MetaMap",        :elements,                                        { include: [PandocObjectFilters::V1_16::Element::MetaValue, PandocObjectFilters::V1_16::Element::Enum] }],
       ["MetaList",       :elements,                                        { include: [PandocObjectFilters::V1_16::Element::MetaValue, PandocObjectFilters::V1_16::Element::Enum] }],
       ["MetaBool",       :value,                                           { include: [PandocObjectFilters::V1_16::Element::MetaValue] }],
       ["MetaString",     :value,                                           { include: [PandocObjectFilters::V1_16::Element::MetaValue] }],
       ["MetaInlines",    :elements,                                        { include: [PandocObjectFilters::V1_16::Element::MetaValue, PandocObjectFilters::V1_16::Element::Enum] }],
       ["MetaBlocks",     :elements,                                        { include: [PandocObjectFilters::V1_16::Element::MetaValue, PandocObjectFilters::V1_16::Element::Enum] }],
       ["Plain",          :elements,                                        { include: [PandocObjectFilters::V1_16::Element::Block, PandocObjectFilters::V1_16::Element::Enum] }],
       ["Para",           :elements,                                        { include: [PandocObjectFilters::V1_16::Element::Block, PandocObjectFilters::V1_16::Element::Enum] }],
       ["CodeBlock",      :attributes, :value,                              { include: [PandocObjectFilters::V1_16::Element::Block], conversions: { attributes: PandocObjectFilters::V1_16::Element::Attr } }],
       ["RawBlock",       :format, :value,                                  { include: [PandocObjectFilters::V1_16::Element::Block] }],
       ["BlockQuote",     :elements,                                        { include: [PandocObjectFilters::V1_16::Element::Block, PandocObjectFilters::V1_16::Element::Enum] }],
       ["OrderedList",    :attributes, :elements,                           { include: [PandocObjectFilters::V1_16::Element::Block, PandocObjectFilters::V1_16::Element::Enum] }],
       ["BulletList",     :elements,                                        { include: [PandocObjectFilters::V1_16::Element::Block, PandocObjectFilters::V1_16::Element::Enum] }],
       ["DefinitionList", :elements,                                        { include: [PandocObjectFilters::V1_16::Element::Block, PandocObjectFilters::V1_16::Element::Enum] }],
       ["Header",         :level, :attributes, :elements,                   { include: [PandocObjectFilters::V1_16::Element::Block, PandocObjectFilters::V1_16::Element::Enum], conversions: { attributes: PandocObjectFilters::V1_16::Element::Attr } }],
       ["HorizontalRule",                                                   { include: [PandocObjectFilters::V1_16::Element::Block] }],
       ["Table",          :captions, :alignments, :widths, :headers, :rows, { include: [PandocObjectFilters::V1_16::Element::Block] }],
       ["Div",            :attributes, :elements,                           { include: [PandocObjectFilters::V1_16::Element::Block, PandocObjectFilters::V1_16::Element::Enum], conversions: { attributes: PandocObjectFilters::V1_16::Element::Attr } }],
       ["Null",                                                             { include: [PandocObjectFilters::V1_16::Element::Block] }],
       ["Str",            :value,                                           { include: [PandocObjectFilters::V1_16::Element::Inline] }],
       ["Emph",           :elements,                                        { include: [PandocObjectFilters::V1_16::Element::Inline, PandocObjectFilters::V1_16::Element::Enum] }],
       ["Strong",         :elements,                                        { include: [PandocObjectFilters::V1_16::Element::Inline, PandocObjectFilters::V1_16::Element::Enum] }],
       ["Strikeout",      :elements,                                        { include: [PandocObjectFilters::V1_16::Element::Inline, PandocObjectFilters::V1_16::Element::Enum] }],
       ["Superscript",    :elements,                                        { include: [PandocObjectFilters::V1_16::Element::Inline, PandocObjectFilters::V1_16::Element::Enum] }],
       ["Subscript",      :elements,                                        { include: [PandocObjectFilters::V1_16::Element::Inline, PandocObjectFilters::V1_16::Element::Enum] }],
       ["SmallCaps",      :elements,                                        { include: [PandocObjectFilters::V1_16::Element::Inline, PandocObjectFilters::V1_16::Element::Enum] }],
       ["Quoted",         :type, :elements,                                 { include: [PandocObjectFilters::V1_16::Element::Inline, PandocObjectFilters::V1_16::Element::Enum] }],
       ["Cite",           :citations, :elements,                            { include: [PandocObjectFilters::V1_16::Element::Inline, PandocObjectFilters::V1_16::Element::Enum] }],
       ["Code",           :attributes, :value,                              { include: [PandocObjectFilters::V1_16::Element::Inline], conversions: { attributes: PandocObjectFilters::V1_16::Element::Attr } }],
       ["Space",                                                            { include: [PandocObjectFilters::V1_16::Element::Inline] }],
       ["SoftBreak",                                                        { include: [PandocObjectFilters::V1_16::Element::Inline] }],
       ["LineBreak",                                                        { include: [PandocObjectFilters::V1_16::Element::Inline] }],
       ["Math",           :type, :value,                                    { include: [PandocObjectFilters::V1_16::Element::Inline] }],
       ["RawInline",      :format, :value,                                  { include: [PandocObjectFilters::V1_16::Element::Inline] }],
       ["Link",           :attributes, :elements, :target,                  { include: [PandocObjectFilters::V1_16::Element::Inline, PandocObjectFilters::V1_16::Element::Enum], conversions: { attributes: PandocObjectFilters::V1_16::Element::Attr, target: PandocObjectFilters::V1_16::Element::Target } }],
       ["Image",          :attributes, :elements, :target,                  { include: [PandocObjectFilters::V1_16::Element::Inline, PandocObjectFilters::V1_16::Element::Enum], conversions: { attributes: PandocObjectFilters::V1_16::Element::Attr, target: PandocObjectFilters::V1_16::Element::Target } }],
       ["Note",           :elements,                                        { include: [PandocObjectFilters::V1_16::Element::Inline, PandocObjectFilters::V1_16::Element::Enum] }],
       ["Span",           :attributes, :elements,                           { include: [PandocObjectFilters::V1_16::Element::Inline, PandocObjectFilters::V1_16::Element::Enum], conversions: { attributes: PandocObjectFilters::V1_16::Element::Attr } }]].each do |name, *params|
        # rubocop:enable Metrics/LineLength
        name.freeze

        options =
          if params.last.is_a?(Hash)
            params.pop
          else
            {}
          end

        const_set(name, Class.new(PandocObjectFilters::V1_16::Element::BaseElement) do
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

                if convert_to_type && !x.is_a?(convert_to_type)
                  convert_to_type.new(x)
                else
                  x
                end
              end
            end
          end
        end)
      end
    end
  end
end
