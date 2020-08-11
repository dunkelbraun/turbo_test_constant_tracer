# frozen_string_literal: true

require "test_helper"

describe "Constructor" do
  describe "#construct" do
    test "constructs class for a string" do
      class_constructor = TurboTest::MethodCallTracerProxy::Constructor.new(String)
      class_constructor.construct
      assert defined?(TurboTest::MethodCallTracerProxy::ProxyKlass::String)
    end

    test "constructs class for an array" do
      class_constructor = TurboTest::MethodCallTracerProxy::Constructor.new(Array)
      class_constructor.construct
      assert defined?(TurboTest::MethodCallTracerProxy::ProxyKlass::Array)
    end

    test "constructs class for an integer" do
      class_constructor = TurboTest::MethodCallTracerProxy::Constructor.new(Integer)
      class_constructor.construct
      assert defined?(TurboTest::MethodCallTracerProxy::ProxyKlass::Integer)
    end

    test "constructs class once" do
      class_constructor = TurboTest::MethodCallTracerProxy::Constructor.new(String)
      assert_output("", "") do
        class_constructor.construct
        class_constructor.construct
        class_constructor.construct
      end
    end
  end

  describe "a constructed class" do
    it "is a Delegator" do
      class_constructor = TurboTest::MethodCallTracerProxy::Constructor.new(String)
      class_constructor.construct
      assert TurboTest::MethodCallTracerProxy::ProxyKlass::String.new("232").is_a?(Delegator)
    end

    it "has the original object class as a class instance variable" do
      TurboTest::MethodCallTracerProxy::Constructor.new(String).construct
      assert_equal String, TurboTest::MethodCallTracerProxy::ProxyKlass::String.turbo_test_proxied_class
    end
  end

  describe "constructed class instance" do
    it "can be only instantiated with an object of the proxied class" do
      TurboTest::MethodCallTracerProxy::Constructor.new(String).construct
      TurboTest::MethodCallTracerProxy::Constructor.new(Array).construct

      exception = assert_raises TypeError do
        TurboTest::MethodCallTracerProxy::ProxyKlass::String.new([])
      end
      assert_equal "Object class is not String", exception.message

      exception = assert_raises TypeError do
        TurboTest::MethodCallTracerProxy::ProxyKlass::Array.new("s")
      end
      assert_equal "Object class is not Array", exception.message
    end

    it "String class has the case equality of String" do
      TurboTest::MethodCallTracerProxy::Constructor.new(String).construct
      # rubocop:disable Style/CaseEquality
      assert String === TurboTest::MethodCallTracerProxy::ProxyKlass::String.new("wewe")
      # rubocop:enable Style/CaseEquality
    end

    test "Fixnum class has the case equality of Fixum" do
      if RUBY_VERSION >= "2.4"
        TurboTest::MethodCallTracerProxy::Constructor.new(Integer).construct
        proxy_int = TurboTest::MethodCallTracerProxy::ProxyKlass::Integer.new(1)
      else
        # rubocop:disable Lint/UnifiedInteger
        TurboTest::MethodCallTracerProxy::Constructor.new(Fixnum).construct
        # rubocop:enable Lint/UnifiedInteger
        proxy_int = TurboTest::MethodCallTracerProxy::ProxyKlass::Fixnum.new(1)
      end
      # rubocop:disable Style/CaseEquality
      assert Integer === proxy_int
      assert Numeric === proxy_int
      assert Comparable === proxy_int
      # rubocop:enable Style/CaseEquality
    end

    test "has the case equality of Comparable" do
      if RUBY_VERSION >= "2.4"
        TurboTest::MethodCallTracerProxy::Constructor.new(Integer).construct
        proxy_int = TurboTest::MethodCallTracerProxy::ProxyKlass::Integer.new(1)
      else
        # rubocop:disable Lint/UnifiedInteger
        TurboTest::MethodCallTracerProxy::Constructor.new(Fixnum).construct
        # rubocop:enable Lint/UnifiedInteger
        proxy_int = TurboTest::MethodCallTracerProxy::ProxyKlass::Fixnum.new(1)
      end
      # rubocop:disable Style/CaseEquality
      assert Comparable === proxy_int
      # rubocop:enable Style/CaseEquality
    end

    test "has the case equalit of Numeric" do
      if RUBY_VERSION >= "2.4"
        TurboTest::MethodCallTracerProxy::Constructor.new(Integer).construct
        proxy_int = TurboTest::MethodCallTracerProxy::ProxyKlass::Integer.new(1)
      else
        # rubocop:disable Lint/UnifiedInteger
        TurboTest::MethodCallTracerProxy::Constructor.new(Fixnum).construct
        # rubocop:enable Lint/UnifiedInteger
        proxy_int = TurboTest::MethodCallTracerProxy::ProxyKlass::Fixnum.new(1)
      end
      # rubocop:disable Style/CaseEquality
      assert Numeric === proxy_int
      # rubocop:enable Style/CaseEquality
    end

    test "original class has the case equality of the instance" do
      TurboTest::MethodCallTracerProxy::Constructor.new(String).construct
      # rubocop:disable Style/CaseEquality
      refute TurboTest::MethodCallTracerProxy::ProxyKlass::String.new("wewe") === String
      # rubocop:enable Style/CaseEquality
    end

    test "constructed class has case equality of the original class" do
      TurboTest::MethodCallTracerProxy::Constructor.new(String).construct
      assert TurboTest::MethodCallTracerProxy::ProxyKlass::String == String
      refute TurboTest::MethodCallTracerProxy::ProxyKlass::String != String
    end

    test "original class has equality of the constructed class" do
      TurboTest::MethodCallTracerProxy::Constructor.new(String).construct
      assert String == TurboTest::MethodCallTracerProxy::ProxyKlass::String
      refute String != TurboTest::MethodCallTracerProxy::ProxyKlass::String
    end

    test "has equality of instance of constructed class" do
      TurboTest::MethodCallTracerProxy::Constructor.new(String).construct
      proxy_string = TurboTest::MethodCallTracerProxy::ProxyKlass::String.new("a_string")
      assert proxy_string == "a_string"
      refute proxy_string != "a_string"
    end

    test "has equality of instance of the original class" do
      TurboTest::MethodCallTracerProxy::Constructor.new(String).construct
      proxy_string = TurboTest::MethodCallTracerProxy::ProxyKlass::String.new("a_string")
      assert proxy_string == "a_string"
      refute proxy_string != "a_string"
    end

    test "has spaceship oerator of the original class" do
      TurboTest::MethodCallTracerProxy::Constructor.new(String).construct
      proxy_string = TurboTest::MethodCallTracerProxy::ProxyKlass::String.new("ab")
      assert_equal 0, "ab" <=> proxy_string
      assert_equal(-1, "aa" <=> proxy_string)
      assert_equal 1, "ac" <=> proxy_string

      assert_equal 0, proxy_string <=> "ab"
      assert_equal 1, proxy_string <=> "aa"
      assert_equal(-1, proxy_string <=> "ac")

      if RUBY_VERSION >= "2.4"
        TurboTest::MethodCallTracerProxy::Constructor.new(Integer).construct
        proxy_int = TurboTest::MethodCallTracerProxy::ProxyKlass::Integer.new(1)
      else
        # rubocop:disable Lint/UnifiedInteger
        TurboTest::MethodCallTracerProxy::Constructor.new(Fixnum).construct
        # rubocop:enable Lint/UnifiedInteger
        proxy_int = TurboTest::MethodCallTracerProxy::ProxyKlass::Fixnum.new(1)
      end

      assert_equal 0, 1 <=> proxy_int
      assert_equal(-1, 0 <=> proxy_int)
      assert_equal 1, 2 <=> proxy_int

      assert_equal 0, proxy_int <=> 1
      assert_equal 1, proxy_int <=> 0
      assert_equal(-1, proxy_int <=> 2)
    end

    test "can have a name" do
      TurboTest::MethodCallTracerProxy::Constructor.new(String).construct
      proxy_string = TurboTest::MethodCallTracerProxy::ProxyKlass::String.new("2323")
      proxy_string.turbo_test_name = "a_name"
      assert_equal "a_name", proxy_string.turbo_test_name
    end

    test "instruments method calls" do
      TurboTest::MethodCallTracerProxy::Constructor.new(String).construct
      original_string = "a_string"
      proxy_string = TurboTest::MethodCallTracerProxy::ProxyKlass::String.new(original_string)
      proxy_string.turbo_test_name = "MY_NAME"
      proxy_string.turbo_test_path = __FILE__

      TurboTest::MethodCallTracerProxy::EventPublisher.instance.expects(:publish).with("MY_NAME", __FILE__)
      proxy_string.to_s
    end
  end
end
