# # frozen_string_literal missing on purpose for tests

require "test_helper"

describe "Delegated Proxy Enumerable" do
  include EnumerableHelper
  include DelegatedTestSetup

  if RUBY_VERSION >= "2.5"
    test "#all" do
      TestClass.const_set(:CONSTANT, %w[dino bear dolphin])
      enumerable_proxy = create_enumerable_proxy
      assert_enumerable_all(enumerable_proxy, /(\w\w\w)(\w)/, true)
    end

    test "#any" do
      TestClass.const_set(:CONSTANT, %w[dino bear dolphin])
      enumerable_proxy = create_enumerable_proxy
      assert_enumerable_any(enumerable_proxy, /(\w\w\w)(\w)/, true)
    end
  end

  test "#grep" do
    TestClass.const_set(:CONSTANT, %w[dino bear dolphin])
    enumerable_proxy = create_enumerable_proxy
    assert_enumerable_grep(enumerable_proxy, /(\w\w\w)(\w)/, true)
  end

  test "#grep_v" do
    TestClass.const_set(:CONSTANT, %w[dino bear dolphin])
    enumerable_proxy = create_enumerable_proxy
    # No match but interested in testing $ variables
    assert_enumerable_grep_v(enumerable_proxy, /(\w\w\w)(\w)/, true)
  end

  if RUBY_VERSION >= "2.5"
    test "#none?" do
      TestClass.const_set(:CONSTANT, %w[dino bear dolphin])
      enumerable_proxy = create_enumerable_proxy
      assert_enumerable_none(enumerable_proxy, /(\w\w\w)(\w\w\w)/, true)
    end

    test "#one?" do
      TestClass.const_set(:CONSTANT, %w[dino bear dolphin])
      enumerable_proxy = create_enumerable_proxy
      assert_enumerable_one(enumerable_proxy, /(\w\w\w)(\w\w)/, true)
    end
  end

  test "#slice_before" do
    TestClass.const_set(:CONSTANT, %w[dino bear dolphin])
    enumerable_proxy = create_enumerable_proxy
    assert_enumerable_slice_before(enumerable_proxy, /(\w\w\w)/, true)
  end

  test "#slice_after" do
    TestClass.const_set(:CONSTANT, %w[dino bear dolphin])
    enumerable_proxy = create_enumerable_proxy
    assert_enumerable_slice_after(enumerable_proxy, /(\w\w\w)/, true)
  end
end
