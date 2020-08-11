# # frozen_string_literal missing on purpose for tests

require "test_helper"

describe "Delegated Proxy String" do
  include StringHelper
  include DelegatedTestSetup

  describe "#gsub" do
    it "returns an enumerator when called without a block" do
      TestClass.const_set(:CONSTANT, "a_string")
      assert_instance_of Enumerator, TestClass::CONSTANT.gsub(/nothing/)

      proxy_string = create_delegated_proxy_string
      assert_instance_of Enumerator, proxy_string.gsub(/nothing/)
    end

    describe "with block" do
      it "has the match, the special variables and publishes an event" do
        TestClass.const_set(:CONSTANT, "a_string")
        proxy_string = create_delegated_proxy_string
        assert_string_gsub(proxy_string, true)
      end

      it "returns the substituted match" do
        expected_match = "aniiring"
        TestClass.const_set(:CONSTANT, "another_string")

        proxy_string = create_delegated_proxy_string
        assert_nil event_subscriber.events
        match = substituted_match(proxy_string, /(other)_(st)/)
        assert_equal expected_match, match
        assert_equal 1, event_subscriber.events.length
      end
    end
  end

  describe "#gsub!" do
    it "returns enumerator when called without a block" do
      TestClass.const_set(:CONSTANT, "a_string")
      proxy_string = create_delegated_proxy_string
      assert_instance_of Enumerator, proxy_string.gsub!(/nothing/)
    end

    describe "with a block" do
      it "has the match, special variables, and publishes an event" do
        TestClass.const_set(:CONSTANT, "a_string")

        proxy_string = create_delegated_proxy_string
        assert_string_gsub!(proxy_string, true)
      end

      it "returns the substituted match" do
        expected_match = "aniiring"
        TestClass.const_set(:CONSTANT, "another_string")

        proxy_string = create_delegated_proxy_string
        assert_nil event_subscriber.events
        match = substituted_match!(proxy_string, /(other)_(st)/)
        assert_equal expected_match, match
        assert_equal 1, event_subscriber.events.length
      end
    end
  end

  describe "#sub" do
    it "susbtitutes the match" do
      TestClass.const_set(:CONSTANT, "a_string")
      proxy_string = create_delegated_proxy_string
      assert_equal "string", proxy_string.sub(/a_/, "")
    end

    describe "with block" do
      it "has the match, special variables, and publishes an event" do
        TestClass.const_set(:CONSTANT, "a_string")
        proxy_string = create_delegated_proxy_string
        assert_string_sub(proxy_string, true)
      end

      it "returns the substituted match" do
        expected_match = "aniiring"
        TestClass.const_set(:CONSTANT, "another_string")

        proxy_string = create_delegated_proxy_string
        assert_nil event_subscriber.events
        match = substituted_match_sub(proxy_string, /(other)_(st)/)
        assert_equal expected_match, match
        assert_equal 1, event_subscriber.events.length
      end
    end
  end

  describe "#sub!" do
    it "substitutes the match" do
      TestClass.const_set(:CONSTANT, "a_string")
      proxy_string = create_delegated_proxy_string
      proxy_string.sub!(/a_/, "")
      assert_equal "string", proxy_string
    end

    describe "with a block" do
      it "has the match, special variable, and publishes an event" do
        TestClass.const_set(:CONSTANT, "a_string")
        proxy_string = create_delegated_proxy_string
        assert_string_sub!(proxy_string, true)
      end

      it "returns the substituted match" do
        expected_match = "aniiring"
        TestClass.const_set(:CONSTANT, "another_string")

        proxy_string = create_delegated_proxy_string
        assert_nil event_subscriber.events
        match = substituted_match_sub!(proxy_string, /(other)_(st)/)
        assert_equal expected_match, match
        assert_equal 1, event_subscriber.events.length
      end
    end
  end

  describe "#scan" do
    it "returns an array" do
      TestClass.const_set(:CONSTANT, "another string")
      proxy_string = create_delegated_proxy_string

      assert_equal(%w[another string], proxy_string.scan(/\w+/))
    end

    it "returns groups" do
      TestClass.const_set(:CONSTANT, "another string")
      proxy_string = create_delegated_proxy_string

      assert_equal([["ano"], ["the"], ["r s"], ["tri"]], proxy_string.scan(/(...)/))
      assert_equal([%w[an ot], ["he", "r "], %w[st ri]], proxy_string.scan(/(..)(..)/))
    end

    it "has the match, special variables, and published an event when called with a block" do
      TestClass.const_set(:CONSTANT, "another string")
      proxy_string = create_delegated_proxy_string

      assert_string_scan(proxy_string, /(...)/, [["ano"], ["the"], ["r s"], ["tri"]], true)
      assert_string_scan_group(proxy_string, /(..)(..)/, [%w[an ot], ["he", "r "], %w[st ri]], true)
    end
  end

  describe "#=~" do
    it "returns the position of the match" do
      TestClass.const_set(:CONSTANT, "wwwww2www")
      proxy_string = create_delegated_proxy_string
      assert_nil event_subscriber.events
      position = proxy_string =~ /(\d)/
      assert_equal 5, position
      assert_equal "2", Regexp.last_match(1)
      assert_equal 1, event_subscriber.events.length

      TurboTest::MethodCallTracerProxy::EventPublisher.instance.reset_call_log

      assert_nil proxy_string =~ /(\d\d)/
      assert_equal 2, event_subscriber.events.length
    end
  end
end
