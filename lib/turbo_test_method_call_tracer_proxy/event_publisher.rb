# frozen_string_literal: true

require "singleton"

module TurboTest
  module MethodCallTracerProxy
    class EventPublisher
      include Singleton

      EVENT = "proxy_object_method_call"

      attr_reader :enabled

      class << self
        def instance
          @instance || Mutex.new.synchronize { @instance ||= new }
        end
      end

      def initialize
        @call_log = {}
        @log_all_events = false
      end

      def reset_call_log
        @call_log = {}
      end

      def publish_all_events!
        @log_all_events = true
      end

      def publish_events_once!
        @log_all_events = false
      end

      def publish(name, location)
        return unless @call_log[name].nil? || @log_all_events == true

        TurboTest::EventRegistry[EVENT].publish(name, location)
        @call_log[name] = true
      end
    end
  end
end
