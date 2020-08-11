# # frozen_string_literal missing on purpose for tests

require "test_helper"

describe "Enumerable" do
  include EnumerableHelper
  include DelegatedTestSetup

  if RUBY_VERSION >= "2.5"
    test "#all" do
      TestClass.const_set(:CONSTANT, %w[dino bear dolphin])
      assert_enumerable_all(TestClass::CONSTANT, /(\w\w\w)(\w)/)
    end

    test "#any?" do
      TestClass.const_set(:CONSTANT, %w[dino bear dolphin])
      assert_enumerable_any(TestClass::CONSTANT, /(\w\w\w)(\w)/)
    end
  end

  test "#grep" do
    TestClass.const_set(:CONSTANT, %w[dino bear dolphin])
    assert_enumerable_grep(TestClass::CONSTANT, /(\w\w\w)(\w)/)
  end

  test "#grep_v" do
    TestClass.const_set(:CONSTANT, %w[dino bear dolphin])
    # No match but interested in testing $ variables
    assert_enumerable_grep_v(TestClass::CONSTANT, /(\w\w\w)(\w)/)
  end

  if RUBY_VERSION >= "2.5"
    test "#none?" do
      TestClass.const_set(:CONSTANT, %w[dino bear dolphin])
      assert_enumerable_none(TestClass::CONSTANT, /(\w\w\w)(\w\w\w)/)
    end

    test "#one?" do
      TestClass.const_set(:CONSTANT, %w[dino bear dolphin])
      assert_enumerable_one(TestClass::CONSTANT, /(\w\w\w)(\w\w)/)
    end
  end

  test "#slice_before" do
    TestClass.const_set(:CONSTANT, %w[dino bear dolphin])
    assert_enumerable_slice_before(TestClass::CONSTANT, /(\w\w\w)/)
  end

  test "#slice_after" do
    TestClass.const_set(:CONSTANT, %w[dino bear dolphin])
    assert_enumerable_slice_after(TestClass::CONSTANT, /(\w\w\w)/)
  end
end
