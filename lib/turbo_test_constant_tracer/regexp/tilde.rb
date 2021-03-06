# frozen_string_literal: true

require "binding_of_caller"
require "English"

module TurboTest
  module ConstantTracer
    class Regexp < TurboTestDelegateClass(::Regexp)
      include ::TurboTest::ConstantTracer::Klass::InstanceMethods
      extend  ::TurboTest::ConstantTracer::Klass::ClassMethods

      def ~
        caller_binding = binding.of_caller(1)
        res = (self =~ caller_binding.eval("$_"))
        caller_binding.local_variable_set(:_turbotest_tilde, $LAST_MATCH_INFO)
        caller_binding.eval("$~=_turbotest_tilde")
        res
      end
    end
  end
end

TurboTest::ConstantTracer::Regexp.turbo_test_proxied_class = ::Regexp
