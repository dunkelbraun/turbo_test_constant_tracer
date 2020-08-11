# frozen_string_literal: true

module DelegatedTestSetup
  def self.included(klass)
    klass.class_eval do
      before do
        define_class("TestClass")
        TurboTest::EventRegistry["proxy_object_method_call"].subscribe(event_subscriber)
        TurboTest::ConstantTracer::EventPublisher.reset_call_log
        event_subscriber.instance_variable_set(:@events, nil)
      end

      after do
        remove_class("TestClass")
        TurboTest::EventRegistry["proxy_object_method_call"].unsubscribe(event_subscriber)
      end
    end
  end
end
