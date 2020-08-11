# # frozen_string_literal missing on purpose for tests

require "test_helper"

describe "Regexp" do
  include RegexpHelper
  include DelegatedTestSetup

  test "#=~" do
    TestClass.const_set(:CONSTANT, /(other)_(st)/)
    string = "another_string"
    assert_equal_tilde_reg_string(TestClass::CONSTANT, string)
    assert_equal_tilde_reg_string(string, TestClass::CONSTANT)
  end

  test "#match" do
    TestClass.const_set(:CONSTANT, /(.)(.)(.)/)
    assert_match(TestClass::CONSTANT, "abc")
  end

  test "#match with block has special variables" do
    TestClass.const_set(:CONSTANT, /(.)(.)(.)/)
    assert_match_with_block(TestClass::CONSTANT, "abc")
  end

  test "#~ with block has special variables" do
    TestClass.const_set(:CONSTANT, /(.)(.)(.)/)
    assert_tilde(TestClass::CONSTANT, "abc")
  end

  test "case equality has special variables" do
    TestClass.const_set(:CONSTANT, /(.)(.)(.)/)
    assert_case_equality(TestClass::CONSTANT, "abc")
  end
end
