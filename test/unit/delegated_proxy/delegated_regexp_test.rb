# # frozen_string_literal missing on purpose for tests

require "test_helper"

describe "Delegated Regexp" do
  include RegexpHelper
  include DelegatedTestSetup

  # =~

  def test_equal_tilde_has_special_variables
    TestClass.const_set(:CONSTANT, /(other)_(st)/)
    proxy_regexp = create_proxy_regexp
    string = "another_string"
    assert_equal_tilde_reg_string(proxy_regexp, string, true)
    assert_equal_tilde_reg_string(string, proxy_regexp, true)
  end

  # match

  def test_match_has_special_variables
    TestClass.const_set(:CONSTANT, /(.)(.)(.)/)
    proxy_regexp = create_proxy_regexp

    assert_match(proxy_regexp, "abc", true)
  end

  def test_match_with_block_has_special_variables
    TestClass.const_set(:CONSTANT, /(.)(.)(.)/)
    proxy_regexp = create_proxy_regexp

    assert_match_with_block(proxy_regexp, "abc", true)
  end

  def test_tilde_has_special_variables
    TestClass.const_set(:CONSTANT, /(.)(.)(.)/)
    proxy_regexp = create_proxy_regexp

    assert_tilde(proxy_regexp, "abc", true)
  end

  def test_case_equality_has_special_variables
    TestClass.const_set(:CONSTANT, /(.)(.)(.)/)
    proxy_regexp = create_proxy_regexp

    assert_case_equality(proxy_regexp, "abc", true)
  end
end
