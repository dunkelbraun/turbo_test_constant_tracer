# frozen_string_literal missing on purpose for tests

require "test_helper"

describe "String" do
  include StringHelper
  include DelegatedTestSetup

  describe "#gsub" do
    describe "without a block" do
      it "returns enumerator" do
        TestClass.const_set(:CONSTANT, "a_string")
        assert_instance_of Enumerator, TestClass::CONSTANT.gsub(/nothing/)
      end
    end

    describe "with block" do
      it "has the match, special variables" do
        TestClass.const_set(:CONSTANT, "a_string")
        assert_string_gsub(TestClass::CONSTANT)
      end

      it "returns substituted match" do
        expected_match = "aniiring"
        TestClass.const_set(:CONSTANT, "another_string")

        match = substituted_match(TestClass::CONSTANT, /(other)_(st)/)
        assert_equal expected_match, match
        assert_nil event_subscriber.events
      end
    end
  end

  describe "#gsub!" do
    describe "without a block" do
      it "returns enumerator" do
        TestClass.const_set(:CONSTANT, "a_string")
        assert_instance_of Enumerator, TestClass::CONSTANT.gsub!(/nothing/)
      end
    end

    describe "with a block" do
      it "has the match and special variables" do
        TestClass.const_set(:CONSTANT, "a_string")
        assert_string_gsub!(TestClass::CONSTANT)
        assert_nil event_subscriber.events
      end

      it "returns the substituted match" do
        expected_match = "aniiring"
        TestClass.const_set(:CONSTANT, "another_string")

        match = substituted_match!(TestClass::CONSTANT, /(other)_(st)/)
        assert_equal expected_match, match
        assert_nil event_subscriber.events
      end
    end
  end

  describe "#sub" do
    describe "without a block" do
      it "substitutes the match" do
        TestClass.const_set(:CONSTANT, "a_string")
        assert_equal "string", TestClass::CONSTANT.sub(/a_/, "")
      end
    end

    describe "with a block" do
      it "has the match and special variables" do
        TestClass.const_set(:CONSTANT, "a_string")
        assert_string_sub(TestClass::CONSTANT)
        assert_nil event_subscriber.events
      end

      it "returns the substituted match" do
        expected_match = "aniiring"
        TestClass.const_set(:CONSTANT, "another_string")

        match = substituted_match_sub(TestClass::CONSTANT, /(other)_(st)/)
        assert_equal expected_match, match
        assert_nil event_subscriber.events
      end
    end
  end

  describe "#sub!" do
    describe "without a block" do
      it "sustitutes the match" do
        TestClass.const_set(:CONSTANT, "a_string")
        TestClass::CONSTANT.sub!(/a_/, "")
        assert_equal "string", TestClass::CONSTANT
      end
    end

    describe "with a block" do
      test "has the match and special variables" do
        TestClass.const_set(:CONSTANT, "a_string")
        assert_string_sub!(TestClass::CONSTANT)
        assert_nil event_subscriber.events
      end

      test "returns the substituted match" do
        expected_match = "aniiring"
        TestClass.const_set(:CONSTANT, "another_string")

        match = substituted_match_sub!(TestClass::CONSTANT, /(other)_(st)/)
        assert_equal expected_match, match
        assert_nil event_subscriber.events
      end
    end
  end

  describe "#scan" do
    it "returns array" do
      TestClass.const_set(:CONSTANT, "another string")
      assert_equal(%w[another string], TestClass::CONSTANT.scan(/\w+/))
    end

    it "returns groups" do
      TestClass.const_set(:CONSTANT, "another string")
      assert_equal([["ano"], ["the"], ["r s"], ["tri"]], TestClass::CONSTANT.scan(/(...)/))
      assert_equal([%w[an ot], ["he", "r "], %w[st ri]], TestClass::CONSTANT.scan(/(..)(..)/))
    end

    describe "with a block" do
      it "has the match and special variables" do
        TestClass.const_set(:CONSTANT, "another string")

        assert_string_scan(TestClass::CONSTANT, /(...)/, [["ano"], ["the"], ["r s"], ["tri"]])
        assert_string_scan_group(TestClass::CONSTANT, /(..)(..)/, [%w[an ot], ["he", "r "], %w[st ri]])
      end
    end
  end

  describe "#=~" do
    it "returns the position of the match" do
      position = "wwwww1www" =~ /(\d)/
      assert_equal 5, position
      assert_equal "1", Regexp.last_match(1)

      assert_nil "wwwww1www" =~ /(\d\d)/
    end
  end
end
