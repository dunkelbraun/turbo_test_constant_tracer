# frozen_string_literal: true

require "test_helper"

class TurboTest::ConstantTracer::HashLookupWithProxyTest < Minitest::Test
  def setup
    TurboTest::ConstantTracer::HashLookupWithProxy.enable
  end

  def teardown
    TurboTest::ConstantTracer::HashLookupWithProxy.disable
  end

  def test_enable_multiple_times_enables_only_once
    TurboTest::ConstantTracer::HashLookupWithProxy.disable

    ::Hash.expects(:prepend).with(TurboTest::ConstantTracer::HashLookupWithProxy::Methods).once
    TurboTest::ConstantTracer::HashLookupWithProxy::Methods.expects(:enable).once
    TurboTest::ConstantTracer::HashLookupWithProxy::Methods.stubs(:disable)

    5.times do
      TurboTest::ConstantTracer::HashLookupWithProxy.enable
    end
  end

  def test_hash_lookup
    hash = {}
    hash[:a] = 1

    assert_equal 1, hash[:a]
  end

  def test_a_symbol_proxy_object_used_as_hash_key_should_use_the_proxied_object_as_key
    symbol_proxy_class = TurboTest::ConstantTracer::Constructor.new(::Symbol).construct
    symbol = :test_key
    proxy_symbol = symbol_proxy_class.new(symbol)
    TurboTest::ConstantTracer::ProxyKlass.proxied_objects[proxy_symbol.object_id] = true

    hash = {}
    hash[proxy_symbol] = 1

    assert_equal 1, hash[proxy_symbol]
    assert_equal 1, hash[:test_key]

    hash = {}
    hash[:test_key] = 1

    assert_equal 1, hash[proxy_symbol]
    assert_equal 1, hash[:test_key]
  end

  def test_a_string_proxy_object_used_as_hash_key_should_use_the_proxied_object_as_key
    string_proxy_class = TurboTest::ConstantTracer::Constructor.new(::String).construct
    string = "a_string"
    proxy_string = string_proxy_class.new(string)
    TurboTest::ConstantTracer::ProxyKlass.proxied_objects[proxy_string.object_id] = true

    hash = {}
    hash[proxy_string] = 1

    assert_equal 1, hash[proxy_string]
    assert_equal 1, hash["a_string"]

    hash = {}
    hash["a_string"] = 1

    assert_equal 1, hash[proxy_string]
    assert_equal 1, hash["a_string"]
  end

  def test_a_proxy_object_used_as_hash_key_should_not_use_the_proxied_object_as_key
    TurboTest::ConstantTracer::HashLookupWithProxy.disable
    symbol_proxy_class = TurboTest::ConstantTracer::Constructor.new(::Symbol).construct
    symbol = :test_key
    proxy_symbol = symbol_proxy_class.new(symbol)
    hash = {}
    hash[proxy_symbol] = 1

    assert_equal 1, hash[proxy_symbol]
    assert_nil hash[:test_key]
  end
end
