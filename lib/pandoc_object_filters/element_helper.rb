require "pandoc_object_filters"

module PandocObjectFilters
  module ElementHelper
    attr_reader :version

    def version=(value)
      raise "The version is already defined!" if @version
      @version = value
    end

    def autoload_elements(*elements)
      raise "autoload_elements can only be called once!" if @autoloaded_elements
      @autoloaded_elements = true
      elements.each do |element|
        version_dir = version.name.split("::").last.downcase
        element_path = element.to_s.gsub(/(\w)([A-Z])/, "\\1_\\2").downcase
        autoload element, "pandoc_object_filters/#{version_dir}/element/#{element_path}"
      end
    end

    def to_ast(object)
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

    def to_object(object)
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

    def walk(object, &block)
      PandocObjectFilters::Walker.new(object, &block).walk
    end

    def walk!(object, &block)
      PandocObjectFilters::Walker.new(object, &block).walk!
    end

    def define_elements(*definitions)
      raise "define_elements can only be called once!" if @defined_elements
      @defined_elements = true
      definitions.each do |name, *params|
        name.freeze

        options =
          if params.last.is_a?(Hash)
            params.pop
          else
            {}
          end

        const_set(name, Class.new(version::Element::BaseElement) do
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
