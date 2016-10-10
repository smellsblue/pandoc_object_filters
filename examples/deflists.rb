#!/usr/bin/env ruby

require "pandoc_object_filters"

def self.tobullet(term, defs)
  elements = [PandocObjectFilters::Element::Para.new([PandocObjectFilters::Element::Strong.new(term)])]
  defs.each do |el|
    el.each do |el_el|
      elements.push(el_el)
    end
  end
  elements
end

def self.bullet_list(items)
  items = items.map { |item| tobullet(item[0], item[1]) }
  PandocObjectFilters::Element::BulletList.new(items)
end

PandocObjectFilters.filter! do |element|
  if element.is_a?(PandocObjectFilters::Element::DefinitionList)
    bullet_list(element.elements)
  end
end
