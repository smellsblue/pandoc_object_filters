require "pandoc_object_filters"

module PandocObjectFilters
  module V1_16
    module Element
      class Attr < PandocObjectFilters::V1_16::Element::Base
        module Behavior
          def self.included(other)
            other.contents_attr :identifier, 0
            other.contents_attr :classes, 1
            other.contents_attr :key_values, 2
            other.extend ClassMethods
          end

          module ClassMethods
            def build(options = {})
              id = options.fetch(:identifier, "")
              classes = options.fetch(:classes, [])
              key_values = options.fetch(:key_values, [])

              key_values = key_values.to_a if key_values.is_a?(Hash)

              new([id, classes, key_values])
            end
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

        include Behavior
      end
    end
  end
end
