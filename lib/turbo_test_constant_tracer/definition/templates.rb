# frozen_string_literal: true

require "binding_of_caller"
require "English"

module TurboTest
  module ConstantTracer
    module DefinitionTemplates
      private

      def define_proxy_enumerable_template_method(singleton_class, name, location, original_method)
        singleton_class.class_eval <<~RUBY, __FILE__, __LINE__ + 1
          def #{original_method}(*args, &block)
            send_block = if block
              Proc.new do |match|
                block_binding = block.binding
                block_binding.local_variable_set(:_turbotest_tilde, $~)
                block_binding.eval("$~=_turbotest_tilde")
                block.call(match)
              end
            else
              block
            end
            result = __turbo_test_tt_proxy_dup_object.#{original_method}(*args, &send_block)
            caller_binding = binding.of_caller(1)
            caller_binding.local_variable_set(:_turbotest_tilde, $~)
            caller_binding.eval("$~=_turbotest_tilde")
            ::TurboTest::ConstantTracer::EventPublisher.publish("#{name}", "#{location}")
            result
          end
        RUBY
      end

      def define_equal_tilde_method(singleton_class, _klass, _name, _location)
        singleton_class.class_eval do
          def =~(other)
            caller_binding = binding.of_caller(1)
            (::String.new(self) =~ other).tap do
              caller_binding.local_variable_set(:_turbotest_tilde, $LAST_MATCH_INFO)
              caller_binding.eval("$~=_turbotest_tilde")
            end
          end
        end
      end

      def alias_original_method(klass, mod_method, original_method)
        klass.class_eval do
          aliased_name = "__turbo_test_#{mod_method}"
          alias_method aliased_name, original_method
          # rubocop:disable Style/AccessModifierDeclarations
          private aliased_name
          # rubocop:enable Style/AccessModifierDeclarations
        end
      end

      def define_proxy_method(singleton_class, klass, _mod_method, name, location)
        singleton_class.class_eval <<~RUBY, __FILE__, __LINE__ + 1
          aliased_name = "__turbo_test_\#\{_mod_method\}"
          define_method _mod_method do |*args, &block|
            result = __send__ aliased_name, *args, &block
            ::TurboTest::ConstantTracer::EventPublisher.publish("#{klass}::#{name}", "#{location}")
            result
          end
        RUBY
      end

      # rubocop:disable Layout/LineLength
      def define_proxy_string_template_method(singleton_class, name, _mod_method, location, original_method)
        singleton_class.class_eval <<~RUBY, __FILE__, __LINE__ + 1
          aliased_name = "__turbo_test_\#\{_mod_method\}"
          define_method :#{original_method} do |*args, &block|
            res = unless block
              __send__(aliased_name, *args)
            else
              my_proc = Proc.new do |match|
                block_binding = block.binding
                block_binding.local_variable_set(:_turbotest_tilde, $~)
                block_binding.eval("$~=_turbotest_tilde")
                block.call(match)
              end
              __send__(aliased_name, *args, &(my_proc))
            end
            ::TurboTest::ConstantTracer::EventPublisher.publish("#{name}", "#{location}")
            res
          end
        RUBY
      end
      # rubocop:enable Layout/LineLength

      def set_class_constant(klass, name, object)
        silence_warnings do
          klass.const_set(name.gsub("::", ""), object)
        end
        object
      end

      def silence_warnings
        old_stderr = $stderr
        $stderr = StringIO.new
        yield
      ensure
        $stderr = old_stderr
      end
    end
  end
end
