require "pandoc_object_filters"

module PandocObjectFilters
  module V1_17
    module Element
      extend PandocObjectFilters::ElementHelper
      self.version = PandocObjectFilters::V1_17

      autoload_elements :Attr,
                        :Base,
                        :BaseElement,
                        :Block,
                        :Document,
                        :Enum,
                        :Inline,
                        :Leaf,
                        :Meta,
                        :MetaValue,
                        :Target

      # rubocop:disable Metrics/LineLength
      define_elements ["MetaMap",        :elements,                                        { include: [PandocObjectFilters::V1_17::Element::MetaValue, PandocObjectFilters::V1_17::Element::Enum] }],
                      ["MetaList",       :elements,                                        { include: [PandocObjectFilters::V1_17::Element::MetaValue, PandocObjectFilters::V1_17::Element::Enum] }],
                      ["MetaBool",       :value,                                           { include: [PandocObjectFilters::V1_17::Element::MetaValue] }],
                      ["MetaString",     :value,                                           { include: [PandocObjectFilters::V1_17::Element::MetaValue] }],
                      ["MetaInlines",    :elements,                                        { include: [PandocObjectFilters::V1_17::Element::MetaValue, PandocObjectFilters::V1_17::Element::Enum] }],
                      ["MetaBlocks",     :elements,                                        { include: [PandocObjectFilters::V1_17::Element::MetaValue, PandocObjectFilters::V1_17::Element::Enum] }],
                      ["Plain",          :elements,                                        { include: [PandocObjectFilters::V1_17::Element::Block, PandocObjectFilters::V1_17::Element::Enum] }],
                      ["Para",           :elements,                                        { include: [PandocObjectFilters::V1_17::Element::Block, PandocObjectFilters::V1_17::Element::Enum] }],
                      ["CodeBlock",      :attributes, :value,                              { include: [PandocObjectFilters::V1_17::Element::Block], conversions: { attributes: PandocObjectFilters::V1_17::Element::Attr } }],
                      ["RawBlock",       :format, :value,                                  { include: [PandocObjectFilters::V1_17::Element::Block] }],
                      ["BlockQuote",     :elements,                                        { include: [PandocObjectFilters::V1_17::Element::Block, PandocObjectFilters::V1_17::Element::Enum] }],
                      ["OrderedList",    :attributes, :elements,                           { include: [PandocObjectFilters::V1_17::Element::Block, PandocObjectFilters::V1_17::Element::Enum] }],
                      ["BulletList",     :elements,                                        { include: [PandocObjectFilters::V1_17::Element::Block, PandocObjectFilters::V1_17::Element::Enum] }],
                      ["DefinitionList", :elements,                                        { include: [PandocObjectFilters::V1_17::Element::Block, PandocObjectFilters::V1_17::Element::Enum] }],
                      ["Header",         :level, :attributes, :elements,                   { include: [PandocObjectFilters::V1_17::Element::Block, PandocObjectFilters::V1_17::Element::Enum], conversions: { attributes: PandocObjectFilters::V1_17::Element::Attr } }],
                      ["HorizontalRule",                                                   { include: [PandocObjectFilters::V1_17::Element::Block, PandocObjectFilters::V1_17::Element::Leaf] }],
                      ["Table",          :captions, :alignments, :widths, :headers, :rows, { include: [PandocObjectFilters::V1_17::Element::Block] }],
                      ["Div",            :attributes, :elements,                           { include: [PandocObjectFilters::V1_17::Element::Block, PandocObjectFilters::V1_17::Element::Enum], conversions: { attributes: PandocObjectFilters::V1_17::Element::Attr } }],
                      ["Null",                                                             { include: [PandocObjectFilters::V1_17::Element::Block, PandocObjectFilters::V1_17::Element::Leaf] }],
                      ["Str",            :value,                                           { include: [PandocObjectFilters::V1_17::Element::Inline] }],
                      ["Emph",           :elements,                                        { include: [PandocObjectFilters::V1_17::Element::Inline, PandocObjectFilters::V1_17::Element::Enum] }],
                      ["Strong",         :elements,                                        { include: [PandocObjectFilters::V1_17::Element::Inline, PandocObjectFilters::V1_17::Element::Enum] }],
                      ["Strikeout",      :elements,                                        { include: [PandocObjectFilters::V1_17::Element::Inline, PandocObjectFilters::V1_17::Element::Enum] }],
                      ["Superscript",    :elements,                                        { include: [PandocObjectFilters::V1_17::Element::Inline, PandocObjectFilters::V1_17::Element::Enum] }],
                      ["Subscript",      :elements,                                        { include: [PandocObjectFilters::V1_17::Element::Inline, PandocObjectFilters::V1_17::Element::Enum] }],
                      ["SmallCaps",      :elements,                                        { include: [PandocObjectFilters::V1_17::Element::Inline, PandocObjectFilters::V1_17::Element::Enum] }],
                      ["Quoted",         :type, :elements,                                 { include: [PandocObjectFilters::V1_17::Element::Inline, PandocObjectFilters::V1_17::Element::Enum] }],
                      ["Cite",           :citations, :elements,                            { include: [PandocObjectFilters::V1_17::Element::Inline, PandocObjectFilters::V1_17::Element::Enum] }],
                      ["Code",           :attributes, :value,                              { include: [PandocObjectFilters::V1_17::Element::Inline], conversions: { attributes: PandocObjectFilters::V1_17::Element::Attr } }],
                      ["Space",                                                            { include: [PandocObjectFilters::V1_17::Element::Inline, PandocObjectFilters::V1_17::Element::Leaf] }],
                      ["SoftBreak",                                                        { include: [PandocObjectFilters::V1_17::Element::Inline, PandocObjectFilters::V1_17::Element::Leaf] }],
                      ["LineBreak",                                                        { include: [PandocObjectFilters::V1_17::Element::Inline, PandocObjectFilters::V1_17::Element::Leaf] }],
                      ["Math",           :type, :value,                                    { include: [PandocObjectFilters::V1_17::Element::Inline] }],
                      ["RawInline",      :format, :value,                                  { include: [PandocObjectFilters::V1_17::Element::Inline] }],
                      ["Link",           :attributes, :elements, :target,                  { include: [PandocObjectFilters::V1_17::Element::Inline, PandocObjectFilters::V1_17::Element::Enum], conversions: { attributes: PandocObjectFilters::V1_17::Element::Attr, target: PandocObjectFilters::V1_17::Element::Target } }],
                      ["Image",          :attributes, :elements, :target,                  { include: [PandocObjectFilters::V1_17::Element::Inline, PandocObjectFilters::V1_17::Element::Enum], conversions: { attributes: PandocObjectFilters::V1_17::Element::Attr, target: PandocObjectFilters::V1_17::Element::Target } }],
                      ["Note",           :elements,                                        { include: [PandocObjectFilters::V1_17::Element::Inline, PandocObjectFilters::V1_17::Element::Enum] }],
                      ["Span",           :attributes, :elements,                           { include: [PandocObjectFilters::V1_17::Element::Inline, PandocObjectFilters::V1_17::Element::Enum], conversions: { attributes: PandocObjectFilters::V1_17::Element::Attr } }]
      # rubocop:enable Metrics/LineLength
    end
  end
end
