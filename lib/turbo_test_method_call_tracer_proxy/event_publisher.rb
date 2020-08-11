# frozen_string_literal: true

require "singleton"

module TurboTest
  module MethodCallTracerProxy
    class EventPublisher
      include Singleton

      EVENT = "proxy_object_method_call"

      attr_reader :enabled

      def initialize
        @call_log = {}
      end

      def reset_call_log
        @call_log = {}
      end

      def publish(name, location)
        return unless @call_log[name].nil?

        TurboTest::EventRegistry[EVENT].publish(name, location)
        @call_log[name] = true
      end
    end
  end
end
