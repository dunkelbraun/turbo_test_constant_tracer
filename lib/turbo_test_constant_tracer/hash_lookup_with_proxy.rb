# frozen_string_literal: true

require_relative "./../hash_lookup_with_proxy_ext"

module TurboTest
  module ConstantTracer
    module HashLookupWithProxy
      class << self
        attr_reader :enabled
      end

      def self.enable
        return if enabled

        Hash.prepend(Methods)
        Methods.enable
        @enabled = true
      end

      def self.disable
        return unless enabled

        Methods.disable
        @enabled = false
      end

      module Methods
        class << self
          def enable
            add_assign_method
          end

          def disable
            class_eval do
              remove_method :[]=
            end
          end
        end
      end
    end
  end
end
