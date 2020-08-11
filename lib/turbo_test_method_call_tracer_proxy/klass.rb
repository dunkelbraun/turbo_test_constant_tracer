# frozen_string_literal: true

require "delegate"
require "binding_of_caller"
require_relative "delegator"
require_relative "delegate_class"
module TurboTest
  module MethodCallTracerProxy
    class Klass
      STRING_METHODS = {
        scan: true, gsub: true, gsub!: true, sub: true, sub!: true, "=~": 1
      }.freeze

      ENUMERABLE_METHODS = {
        all?: true, any?: true, grep: true, grep_v: true,
        none?: true, one?: true, slice_before: true, slice_after: true
      }.freeze

      REGEXP_METHODS = {
        match: 1, "=~": 1, "===": 1
      }.freeze

      def self.define(original_class, name)
        return ::TurboTest::MethodCallTracerProxy::Regexp if original_class == ::Regexp

        klass = Class.new(TurboTestDelegateClass(original_class)) do
          include InstanceMethods
          extend  ClassMethods
        end
        klass.turbo_test_proxied_class = original_class
        ProxyKlass.const_set name, klass
        klass
      end

      module ClassMethods
        attr_accessor :turbo_test_proxied_class

        def ==(other)
          turbo_test_proxied_class == other
        end
      end

      module InstanceMethods
        attr_accessor :turbo_test_name, :turbo_test_path

        def initialize(object)
          super
          check_object_type!(object)
        end

        def __getobj__
          result = super
          TurboTest::MethodCallTracerProxy::EventPublisher.instance.publish(
            turbo_test_name, turbo_test_path
          )
          result
        end

        def turbo_test_proxied_class
          __getobj__
        end
        alias __turbo_test_proxy_object turbo_test_proxied_class

        private

        def check_object_type!(object)
          return if object.class == self.class.turbo_test_proxied_class

          msg = "Object class is not #{self.class.turbo_test_proxied_class}"
          raise(TypeError, msg)
        end
      end
    end
  end
end
