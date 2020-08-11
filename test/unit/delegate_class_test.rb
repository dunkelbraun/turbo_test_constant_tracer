# frozen_string_literal: true

# Adapted from: https://github.com/ruby/ruby/blob/v2_7_1/test/test_delegate.rb

require "delegate"
require "test_helper"

class TestDelegateClass < Minitest::Test
  module M
    attr_reader :m
  end

  def test_extend
    obj = TurboTestDelegateClass(Array).new([])
    obj.instance_eval { @m = :m }
    obj.extend M
    assert_equal(:m, obj.m, "[ruby-dev:33116]")
  end

  def test_systemcallerror_eq
    e = SystemCallError.new(0)
    assert((SimpleDelegator.new(e) == e) == (e == SimpleDelegator.new(e)), "[ruby-dev:34808]")
  end

  class Myclass < TurboTestDelegateClass(Array); end

  def test_delegateclass_class
    myclass = Myclass.new([])
    assert_equal(Myclass, myclass.class)
    assert_equal(Myclass, myclass.dup.class, "[ruby-dev:40313]")
    assert_equal(Myclass, myclass.clone.class, "[ruby-dev:40313]")
  end

  def test_simpledelegator_class
    simple = SimpleDelegator.new([])
    assert_equal(SimpleDelegator, simple.class)
    assert_equal(SimpleDelegator, simple.dup.class)
    assert_equal(SimpleDelegator, simple.clone.class)
  end

  class Object
    def m
      :o
    end

    private

    def delegate_test_m
      :o
    end
  end

  class Foo
    def m
      :m
    end

    def delegate_test_m
      :m
    end
  end

  class Bar < TurboTestDelegateClass(Foo)
  end

  def test_override
    foo = Foo.new
    foo2 = SimpleDelegator.new(foo)
    bar = Bar.new(foo)
    assert_equal(:o, Object.new.m)
    assert_equal(:m, foo.m)
    assert_equal(:m, foo2.m)
    assert_equal(:m, bar.m)
    bug = "[ruby-dev:39154]"
    assert_equal(:m, foo2.send(:delegate_test_m), bug)
    assert_equal(:m, bar.send(:delegate_test_m), bug)
  end

  class Parent
    def parent_public; end

    protected

    def parent_protected; end
  end

  class Child < TurboTestDelegateClass(Parent)
  end

  class Parent
    def parent_public_added; end

    protected

    def parent_protected_added; end
  end

  def test_public_instance_methods
    ignores = Object.public_instance_methods | Delegator.public_instance_methods
    assert_equal(%i[parent_public parent_public_added].sort, (Child.public_instance_methods - ignores).sort)
    assert_equal(%i[parent_public parent_public_added].sort, (Child.new(Parent.new).public_methods - ignores).sort)
  end

  def test_protected_instance_methods
    ignores = Object.protected_instance_methods | Delegator.protected_instance_methods
    assert_equal(%i[parent_protected parent_protected_added].sort, (Child.protected_instance_methods - ignores).sort)
    assert_equal(%i[parent_protected parent_protected_added].sort, (Child.new(Parent.new).protected_methods - ignores).sort)
  end

  class IV < TurboTestDelegateClass(Integer)
    attr_accessor :var

    def initialize
      @var = 1
      super(0)
    end
  end

  def test_marshal
    bug1744 = "[ruby-core:24211]"
    c = IV.new
    assert_equal(1, c.var)
    d = Marshal.load(Marshal.dump(c))
    assert_equal(1, d.var, bug1744)
  end

  def test_copy_frozen
    a = [42, :hello].freeze
    d = SimpleDelegator.new(a)
    d.dup[0] += 1
    assert_raises(RuntimeError) { d.clone[0] += 1 }
    d.freeze
    assert(d.clone.frozen?)
    assert(!d.dup.frozen?)
  end

  def test_frozen
    d = SimpleDelegator.new([1, :foo])
    d.freeze
    assert_raises(RuntimeError, "[ruby-dev:40314]#1") { d.__setobj__("foo") }
    assert_equal([1, :foo], d)
  end

  def test_instance_method
    s = SimpleDelegator.new("foo")
    m = s.method("upcase")
    s.__setobj__([1, 2, 3])
    assert_raises(NoMethodError, "[ruby-dev:40314]#3") { m.call }
  end

  def test_methods
    s = SimpleDelegator.new("foo")
    assert_equal([], s.methods(false))
    def s.bar; end
    assert_equal([:bar], s.methods(false))
  end

  class Foo
    private

    def delegate_test_private
      :m
    end
  end

  def test_private_method
    foo = Foo.new
    d = SimpleDelegator.new(foo)
    assert_raises(NoMethodError) { foo.delegate_test_private }
    assert_equal(:m, foo.send(:delegate_test_private))
    assert_raises(NoMethodError, "[ruby-dev:40314]#4") { d.delegate_test_private }
    assert_raises(NoMethodError, "[ruby-dev:40314]#5") { d.send(:delegate_test_private) }
  end

  def test_global_function
    klass = Class.new do
      def open; end
    end
    obj = klass.new
    d = SimpleDelegator.new(obj)
    obj.open
    d.open
    d.send(:open)
  end

  def test_send_method_in_delegator
    d = Class.new(SimpleDelegator) do
      def foo
        "foo"
      end
    end.new(Object.new)
    assert_equal("foo", d.send(:foo))
  end

  def test_unset_simple_delegator
    d = SimpleDelegator.allocate
    exception = assert_raises(ArgumentError) do
      d.__getobj__
    end
    assert exception.message.match(/not delegated/)
  end

  def test_unset_delegate_class
    d = IV.allocate
    exception = assert_raises(ArgumentError) do
      d.__getobj__
    end
    assert exception.message.match(/not delegated/)
  end

  class Bug9155 < TurboTestDelegateClass(Integer)
    def initialize(value)
      super(Integer(value))
    end
  end

  def test_global_method_if_no_target
    bug9155 = "[ruby-core:58572] [Bug #9155]"
    x = Bug9155.new(1)
    assert_equal(1, x.to_i, bug9155)
  end

  class Bug9403
    Name = "[ruby-core:59718] [Bug #9403]"
    SD = SimpleDelegator.new(new)
    class << SD
      def method_name
        __method__
      end

      def callee_name
        __callee__
      end
      alias aliased_name callee_name
      def dir_name
        __dir__
      end
    end
    dc = DelegateClass(self)
    dc.class_eval do
      def method_name
        __method__
      end

      def callee_name
        __callee__
      end
      alias_method :aliased_name, :callee_name
      def dir_name
        __dir__
      end
    end
    DC = dc.new(new)
  end

  def test_method_in_simple_delegator
    assert_equal(:method_name, Bug9403::SD.method_name, Bug9403::Name)
  end

  def test_callee_in_simple_delegator
    assert_equal(:callee_name, Bug9403::SD.callee_name, Bug9403::Name)
    assert_equal(:aliased_name, Bug9403::SD.aliased_name, Bug9403::Name)
  end

  def test_dir_in_simple_delegator
    assert_equal(__dir__, Bug9403::SD.dir_name, Bug9403::Name)
  end

  def test_method_in_delegator_class
    assert_equal(:method_name, Bug9403::DC.method_name, Bug9403::Name)
  end

  def test_callee_in_delegator_class
    assert_equal(:callee_name, Bug9403::DC.callee_name, Bug9403::Name)
    assert_equal(:aliased_name, Bug9403::DC.aliased_name, Bug9403::Name)
  end

  def test_dir_in_delegator_class
    assert_equal(__dir__, Bug9403::DC.dir_name, Bug9403::Name)
  end
end
