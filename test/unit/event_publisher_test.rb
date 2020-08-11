# frozen_string_literal: true

require "test_helper"

describe "EventPublisher" do
  before do
    TurboTest::MethodCallTracerProxy::EventPublisher.reset_call_log
    TurboTest::EventRegistry["proxy_object_method_call"].subscribe(event_subscriber)
  end

  after do
    TurboTest::MethodCallTracerProxy::EventPublisher.publish_events_once!
    TurboTest::EventRegistry["proxy_object_method_call"].unsubscribe(event_subscriber)
  end

  test "publish once per name by default" do
    4.times do
      TurboTest::MethodCallTracerProxy::EventPublisher.publish("a_name", "a_location")
    end
    assert_equal [%w[a_name a_location]], event_subscriber.events

    TurboTest::MethodCallTracerProxy::EventPublisher.reset_call_log

    4.times do
      TurboTest::MethodCallTracerProxy::EventPublisher.publish("a_name", "a_location")
    end
    assert_equal [%w[a_name a_location], %w[a_name a_location]], event_subscriber.events
  end

  test "publish all events with the same name" do
    TurboTest::MethodCallTracerProxy::EventPublisher.publish_all_events!

    4.times do
      TurboTest::MethodCallTracerProxy::EventPublisher.publish("a_name", "a_location")
    end

    expected_events = [
      %w[a_name a_location], %w[a_name a_location],
      %w[a_name a_location], %w[a_name a_location]
    ]
    assert_equal expected_events, event_subscriber.events
  end
end
