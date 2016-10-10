require "pandoc_object_filters"

module PandocObjectFilters
  class Walker
    def initialize(object, &block)
      @object = object
      @block = block
    end

    def walk(object = @object)
      if object.is_a?(Array)
        object.each do |item|
          if item.is_a?(PandocObjectFilters::Element::BaseElement)
            @block.call(item)
          end

          walk(item)
        end
      elsif object.is_a?(Hash)
        object.values.each do |value|
          walk(value)
        end
      elsif object.is_a?(PandocObjectFilters::Element::Base)
        walk(object.contents)
      end

      object
    end

    def walk!(object = @object)
      if object.is_a?(Array)
        result = []
        object.each do |item|
          if item.is_a?(PandocObjectFilters::Element::BaseElement)
            res = @block.call(item)
            if !res
              result.push(walk!(item))
            elsif res.is_a?(Array)
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
      elsif object.is_a?(Hash)
        result = {}
        object.each do |key, value|
          result[key] = walk!(value)
        end
        return result
      elsif object.is_a?(PandocObjectFilters::Element::Base)
        object.contents = walk!(object.contents)
        return object
      else
        return object
      end
    end
  end
end
