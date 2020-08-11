# frozen_string_literal: true

require "test_helper"

describe "Proxy" do
  before do
    TurboTest::EventRegistry["proxy_object_method_call"].subscribe(event_subscriber)
    event_subscriber.instance_variable_set(:@events, nil)
    self.class.const_set("A_STRING", "a_string")
  end

  after do
    self.class.send(:remove_const, "A_STRING") if self.class.const_defined?("A_STRING")
  end

  let(:subject) { TurboTest::MethodCallTracerProxy::Definition }

  test "define a proxy object" do
    proxy_object = subject.delegator_proxy(self.class, "A_STRING", self.class.const_get("A_STRING"), __FILE__)
    assert_equal TurboTest::MethodCallTracerProxy::ProxyKlass::String, proxy_object.class
    assert_equal "a_string", proxy_object.to_s
  end

  test "define a prody object with name" do
    proxy_object = subject.delegator_proxy(self.class, "A_STRING", self.class.const_get("A_STRING"), __FILE__)
    assert_equal "Proxy::A_STRING", proxy_object.turbo_test_name
  end

  test "define an internal proxy for an object duplicates a frozen object" do
    self.class.const_get("A_STRING").freeze
    original_id = self.class.const_get("A_STRING").object_id

    proxy_object = subject.internal_proxy(self.class, "A_STRING", self.class.const_get("A_STRING"), __FILE__)

    assert_internal_proxy proxy_object

    assert_equal proxy_object.to_s, self.class.const_get("A_STRING").to_s
    assert proxy_object.frozen?
    refute_equal proxy_object.object_id, original_id
  end

  test "define an internal proxy for an object trigger events when calling instance methods" do
    proxy_object = subject.internal_proxy(self.class, "A_STRING", self.class.const_get("A_STRING"), __FILE__)

    assert_internal_proxy proxy_object

    TurboTest::EventRegistry["proxy_object_method_call"].subscribe(event_subscriber)
    TurboTest::MethodCallTracerProxy::EventPublisher.instance.reset_call_log
    event_subscriber.instance_variable_set(:@events, nil)

    proxy_object.to_s

    assert_equal 1, event_subscriber.events.length
    assert_equal "Proxy::A_STRING", event_subscriber.events.first[0]
    assert_equal __FILE__, event_subscriber.events.first[1]
  end

  test "define an internal proxy for an frozen object trigger events when calling instance methods" do
    self.class.const_get("A_STRING").freeze

    proxy_object = subject.internal_proxy(self.class, "A_STRING", self.class.const_get("A_STRING"), __FILE__)

    assert_internal_proxy proxy_object

    TurboTest::EventRegistry["proxy_object_method_call"].subscribe(event_subscriber)
    TurboTest::MethodCallTracerProxy::EventPublisher.instance.reset_call_log
    event_subscriber.instance_variable_set(:@events, nil)

    proxy_object.to_s

    assert_equal 1, event_subscriber.events.length
    assert_equal "Proxy::A_STRING", event_subscriber.events.first[0]
    assert_equal __FILE__, event_subscriber.events.first[1]
  end

  private

  def assert_internal_proxy(object)
    turbo_test_method = object.__send__(:private_methods).find do |method|
      method.to_s.match(/__turbo_test_/)
    end
    refute_nil turbo_test_method
  end
end
