#!/usr/bin/env ruby

require 'pandoc_object_filters'

def self.tobullet(term, defs)
  elements = [ PandocObjectFilters::Element.Para([PandocObjectFilters::Element.Strong(term)]) ]
  defs.each do |el|
    el.each do |el_el|
      elements.push(el_el)
    end
  end
  return elements
end

def self.bullet_list(items)
  items = items.map{|item| tobullet(item[0],item[1])}
  PandocObjectFilters::Element.BulletList(items)
end

PandocObjectFilters::Filter.filter do |type,value,format,meta|
  if type == 'DefinitionList'
    bullet_list(value)
  end
end
