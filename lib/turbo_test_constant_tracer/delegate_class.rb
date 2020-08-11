# frozen_string_literal: true

require "delegate"

def TurboTestDelegateClass(superclass)
  klass = Class.new(Delegator)
  ignores = [*::Delegator.public_api, :to_s, :inspect, :=~, :!~, :===]
  protected_instance_methods = superclass.protected_instance_methods
  protected_instance_methods -= ignores
  public_instance_methods = superclass.public_instance_methods
  public_instance_methods -= ignores

  klass.module_eval do
    def __getobj__ # :nodoc:
      unless defined?(@delegate_dc_obj)
        return yield if block_given?

        __raise__ ::ArgumentError, "not delegated"
      end
      @delegate_dc_obj
    end

    def __setobj__(obj) # :nodoc:
      # Not needed since we are controlling which classes are delegated
      # __raise__ ::ArgumentError, "cannot delegate to self" if self.equal?(obj)
      @delegate_dc_obj = obj
    end

    protected_instance_methods.each do |method|
      klass.send(:define_method, method, Delegator.delegating_block(method))
      protected method
    end

    public_instance_methods.each do |method|
      if (superclass == String && TurboTest::ConstantTracer::Klass::STRING_METHODS[method]) ||
        (superclass.ancestors.include?(Enumerable) &&
          TurboTest::ConstantTracer::Klass::ENUMERABLE_METHODS[method])
        klass.send(
          :define_method,
          method,
          Delegator.delegating_block_with_binding_for_ruby(method)
        )
      else
        klass.send(:define_method, method, Delegator.delegating_block(method))
      end
    end

    if superclass == String || superclass.ancestors.include?(::String)
      method_name = "=~".to_sym
      klass.send(
        :define_method,
        method_name,
        Delegator.delegating_block_with_binding_for_ruby(method_name)
      )
    end

    if superclass == Regexp || superclass.ancestors.include?(::Regexp)
      TurboTest::ConstantTracer::Klass::REGEXP_METHODS.each_key do |key|
        klass.send(:remove_method, key) if klass.method_defined?(key)
        klass.send(:define_method, key, Delegator.delegating_block_with_binding_for_ruby(key))
      end
    end
  end

  klass.define_singleton_method :public_instance_methods do |all = true|
    super(all) | superclass.public_instance_methods
  end
  klass.define_singleton_method :protected_instance_methods do |all = true|
    super(all) | superclass.protected_instance_methods
  end
  klass
end
