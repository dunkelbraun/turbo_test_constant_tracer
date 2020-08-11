# frozen_string_literal: true

module StringHelper
  def create_internal_proxy_string
    proxy_string = TurboTest::MethodCallTracerProxy::Definition.internal_proxy(TestClass, "CONSTANT", TestClass::CONSTANT, "a/path.rb")
    TurboTest::MethodCallTracerProxy::EventPublisher.reset_call_log
    event_subscriber.instance_variable_set(:@events, nil)
    proxy_string
  end

  def create_delegated_proxy_string
    proxy_string = TurboTest::MethodCallTracerProxy::Definition.delegator_proxy(TestClass, "CONSTANT", TestClass::CONSTANT, "a/path.rb")
    TurboTest::MethodCallTracerProxy::EventPublisher.reset_call_log
    event_subscriber.instance_variable_set(:@events, nil)
    proxy_string
  end

  def assert_string_gsub(string, events = false)
    string.gsub(/(s)(t)(r)/) do |match|
      assert_equal "str", match
      assert_equal "s", Regexp.last_match(1)
      assert_equal "t", Regexp.last_match(2)
      assert_equal "r", Regexp.last_match(3)
    end
    assert_events(events)
  end

  def assert_string_gsub!(string, events = false)
    string.gsub!(/(s)(t)(r)/) do |match|
      assert_equal "str", match
      assert_equal "s", Regexp.last_match(1)
      assert_equal "t", Regexp.last_match(2)
      assert_equal "r", Regexp.last_match(3)
    end
    assert_events(events)
  end

  def assert_string_sub(string, events = false)
    string.sub(/(s)(t)(r)/) do |match|
      assert_equal "str", match
      assert_equal "s", Regexp.last_match(1)
      assert_equal "t", Regexp.last_match(2)
      assert_equal "r", Regexp.last_match(3)
    end
    assert_events(events)
  end

  def assert_string_sub!(string, events = false)
    string.sub!(/(s)(t)(r)/) do |match|
      assert_equal "str", match
      assert_equal "s", Regexp.last_match(1)
      assert_equal "t", Regexp.last_match(2)
      assert_equal "r", Regexp.last_match(3)
    end
    assert_events(events)
  end

  def assert_string_scan(string, regexp, expected_match, events = false)
    matches = []
    variables = []
    string.scan(regexp) do |match|
      matches << match
      variables << Regexp.last_match(1)
    end
    assert_equal expected_match, matches
    assert_equal expected_match.flatten, variables
    assert_events(events)
  end

  def assert_string_scan_group(string, regexp, expected_match, events = false)
    matches = []
    variables = []
    string.scan(regexp) do |match|
      matches << match
      variables << "#{Regexp.last_match(1)}#{Regexp.last_match(2)}"
    end
    assert_equal expected_match, matches
    assert_equal expected_match.map(&:join), variables
    assert_events(events)
  end

  def substituted_match(string, regexp)
    string.gsub(regexp) do |_match|
      "ii"
    end
  end

  def substituted_match!(string, regexp)
    string.gsub!(regexp) do |_match|
      "ii"
    end
  end

  def substituted_match_sub(string, regexp)
    string.sub(regexp) do |_match|
      "ii"
    end
  end

  def substituted_match_sub!(string, regexp)
    string.sub!(regexp) do |_match|
      "ii"
    end
  end

  def assert_events(events)
    if events
      assert_equal [["TestClass::CONSTANT", "a/path.rb"]], event_subscriber.events
    else
      assert_nil event_subscriber.events
    end
  end
end
