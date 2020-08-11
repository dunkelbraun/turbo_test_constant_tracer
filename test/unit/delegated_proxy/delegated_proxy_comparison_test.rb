# frozen_string_literal missing on purpose for tests

require "test_helper"

describe "Delegated Proxy comparison" do
  include DelegatedTestSetup

  describe "triggers an event" do
    before do
      TestClass.const_set(:CONSTANT, %w[one])
      TurboTest::ConstantTracer::Definition.delegator_proxy(TestClass, "CONSTANT", TestClass::CONSTANT, "a/path.rb")
    end

    test "comparing an array to a delegated proxy" do
      ["one"].send(:==, TestClass::CONSTANT)
      assert_equal [["TestClass::CONSTANT", "a/path.rb"]], event_subscriber.events
    end

    test "comparing a string to a delegated proxy" do
      "String".send(:==, TestClass::CONSTANT)
      assert_equal [["TestClass::CONSTANT", "a/path.rb"]], event_subscriber.events
    end

    test "comparing an integer to a delegated proxy" do
      1.send(:==, TestClass::CONSTANT)
      assert_equal [["TestClass::CONSTANT", "a/path.rb"]], event_subscriber.events
    end
  end
end
