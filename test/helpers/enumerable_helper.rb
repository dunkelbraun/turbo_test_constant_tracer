# frozen_string_literal: true

module EnumerableHelper
  def create_enumerable_proxy
    enumerable_proxy = TurboTest::ConstantTracer::Definition.delegator_proxy(
      TestClass, "CONSTANT", TestClass::CONSTANT, "a/path.rb"
    )
    TurboTest::ConstantTracer::EventPublisher.reset_call_log
    event_subscriber.instance_variable_set(:@events, nil)
    enumerable_proxy
  end

  def create_enumerable_internal_proxy
    enumerable_proxy = TurboTest::ConstantTracer::Definition.internal_proxy(
      TestClass, "CONSTANT", TestClass::CONSTANT, "a/path.rb"
    )
    TurboTest::ConstantTracer::EventPublisher.reset_call_log
    event_subscriber.instance_variable_set(:@events, nil)
    enumerable_proxy
  end

  def assert_enumerable_all(enumerable, regexp, events = false)
    assert_nil event_subscriber.events
    assert_nil Regexp.last_match(1)
    assert_nil Regexp.last_match(2)
    assert enumerable.all?(regexp)
    assert_equal "dol", Regexp.last_match(1)
    assert_equal "p", Regexp.last_match(2)
    assert_events(events)
  end

  def assert_enumerable_any(enumerable, regexp, events = false)
    assert_nil event_subscriber.events
    assert_nil Regexp.last_match(1)
    assert_nil Regexp.last_match(2)
    assert enumerable.any?(regexp)
    assert_equal "din", Regexp.last_match(1)
    assert_equal "o", Regexp.last_match(2)
    assert_events(events)
  end

  def assert_enumerable_grep(enumerable, regexp, events = false)
    assert_nil event_subscriber.events
    assert_nil Regexp.last_match(1)
    assert_nil Regexp.last_match(2)
    assert_equal(%w[dino bear dolphin], enumerable.grep(regexp))
    words = []
    special_vars = []
    enumerable.grep(regexp) do |word|
      words << word
      special_vars << [Regexp.last_match(1), Regexp.last_match(2)]
    end
    assert_equal(%w[dino bear dolphin], words)
    assert_equal([%w[din o], %w[bea r], %w[dol p]], special_vars)
    assert_equal "dol", Regexp.last_match(1)
    assert_equal "p", Regexp.last_match(2)
    assert_events(events)
  end

  def assert_enumerable_grep_v(enumerable, regexp, events = false)
    assert_nil event_subscriber.events
    assert_nil Regexp.last_match(1)
    assert_nil Regexp.last_match(2)
    assert_equal(%w[dino bear dolphin], enumerable.grep(regexp))
    words = []
    special_vars = []
    enumerable.grep_v(regexp) do |word|
      words << word
      special_vars << [Regexp.last_match(1), Regexp.last_match(2)]
    end
    assert words.empty?
    assert special_vars.empty?
    assert_equal "dol", Regexp.last_match(1)
    assert_equal "p", Regexp.last_match(2)
    assert_events(events)
  end

  def assert_enumerable_none(enumerable, regexp, events = false)
    assert_nil event_subscriber.events
    assert_nil Regexp.last_match(1)
    assert_nil Regexp.last_match(2)
    refute enumerable.none?(regexp)
    assert_equal "dol", Regexp.last_match(1)
    assert_equal "phi", Regexp.last_match(2)
    assert_events(events)
  end

  def assert_enumerable_one(enumerable, regexp, events = false)
    assert_nil event_subscriber.events
    assert_nil Regexp.last_match(1)
    assert_nil Regexp.last_match(2)
    assert enumerable.one?(regexp)
    assert_equal "dol", Regexp.last_match(1)
    assert_equal "ph", Regexp.last_match(2)
    assert_events(events)
  end

  def assert_enumerable_slice_before(enumerable, regexp, events = false)
    assert_nil event_subscriber.events
    assert_nil Regexp.last_match(1)
    assert_nil Regexp.last_match(2)
    assert_equal([["dino"], ["bear"], ["dolphin"]], enumerable.slice_before(regexp).to_a)
    assert_equal "dol", Regexp.last_match(1)
    assert_nil Regexp.last_match(2)
    assert_events(events)
  end

  def assert_enumerable_slice_after(enumerable, regexp, events = false)
    assert_nil event_subscriber.events
    assert_nil Regexp.last_match(1)
    assert_nil Regexp.last_match(2)
    assert_equal([["dino"], ["bear"], ["dolphin"]], enumerable.slice_after(regexp).to_a)
    assert_equal "dol", Regexp.last_match(1)
    assert_nil Regexp.last_match(2)
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
