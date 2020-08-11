# frozen_string_literal: true

module TurboTest
  module ConstantTracer
    class Constructor
      def initialize(original_class)
        @klass = original_class
        @klass_name = original_class.name.gsub("::", "")
      end

      def construct
        return ProxyKlass.const_get(@klass_name) if proxy_class_defined?

        Klass.define(@klass, @klass_name).tap do
          prepend_equality_operators_to_original_class
          prepend_equality_operators Numeric
          prepend_equality_operators Comparable
        end
      end

      private

      def proxy_class_defined?
        ProxyKlass.const_defined? @klass_name, false
      end

      def prepend_equality_operators_to_original_class
        s_class = @klass.singleton_class
        s_class.prepend(CaseEquality)
        s_class.prepend(Equality)
      end

      def prepend_equality_operators(mod)
        return unless @klass.ancestors.include?(mod)

        mod.singleton_class.prepend(CaseEquality)
        mod.singleton_class.prepend(Equality)
      end
    end

    module CaseEquality
      def ===(other)
        if other.respond_to?(:turbo_test_proxied_class)
          other = (other.turbo_test_proxied_class || other)
        end
        super
      end
    end

    module Equality
      def ==(other)
        if other.respond_to?(:turbo_test_proxied_class)
          other = (other.turbo_test_proxied_class || other)
        end
        super
      end
    end
  end
end
