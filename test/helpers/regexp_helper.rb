# frozen_string_literal: true

module RegexpHelper
  def create_proxy_regexp
    proxy_regexp = TurboTest::MethodCallTracerProxy::Definition.delegator_proxy(TestClass, "CONSTANT", TestClass::CONSTANT, "a/path.rb")
    TurboTest::MethodCallTracerProxy::EventPublisher.instance.reset_call_log
    event_subscriber.instance_variable_set(:@events, nil)
    proxy_regexp
  end

  def assert_equal_tilde_reg_string(regexp, string, events = false)
    TurboTest::MethodCallTracerProxy::EventPublisher.instance.reset_call_log
    event_subscriber.instance_variable_set(:@events, nil)
    res = regexp =~ string
    assert_equal 2, res
    assert_equal "other", Regexp.last_match(1)
    assert_equal "st", Regexp.last_match(2)
    assert_events(events)
  end

  def assert_match(regexp, _str, events = false)
    TurboTest::MethodCallTracerProxy::EventPublisher.instance.reset_call_log
    event_subscriber.instance_variable_set(:@events, nil)
    match = regexp.match("abc")
    assert_equal "a", match[1]
    assert_equal "a", Regexp.last_match(1)
    assert_equal "b", match[2]
    assert_equal "b", Regexp.last_match(2)
    assert_equal "c", match[3]
    assert_equal "c", Regexp.last_match(3)
    assert_events(events)
  end

  def assert_match_with_block(regexp, _str, events = false)
    matches = []
    vars = []
    regexp.match("abc") do |match|
      matches << match[1]
      matches << match[2]
      matches << match[3]
      vars << Regexp.last_match(1)
      vars << Regexp.last_match(2)
      vars << Regexp.last_match(3)
    end
    assert_equal %w[a b c], matches
    assert_equal %w[a b c], vars
    assert_events(events)
  end

  # rubocop:disable Lint/Void
  def assert_tilde(regexp, str, events = false)
    $_ = str
    ~ regexp
    assert_equal "a", Regexp.last_match(1)
    assert_equal "b", Regexp.last_match(2)
    assert_equal "c", Regexp.last_match(3)
    assert_events(events)
  end
  # rubocop:enable Lint/Void

  def assert_case_equality(regexp, str, events = false)
    vars = []
    case str
    when regexp
      vars << Regexp.last_match(1)
      vars << Regexp.last_match(2)
      vars << Regexp.last_match(3)
    end
    assert_equal %w[a b c], vars
    assert_events(events)
  end

  def assert_events(events)
    if events
      assert_equal [["TestClass::CONSTANT", "a/path.rb"]], event_subscriber.events
    else
      assert_nil event_subscriber.events
    end
  end
end
