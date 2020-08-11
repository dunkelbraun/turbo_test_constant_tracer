# frozen_string_literal: true

require "delegate"
require "binding_of_caller"
require "English"

# :nocov:
def Delegator.delegating_block_with_binding_for_ruby(mid)
  if RUBY_VERSION >= "2.7"
    Delegator.delegating_block_with_binding_ruby_27(mid)
  else
    Delegator.delegating_block_with_binding(mid)
  end
end

# rubocop:disable Metrics/MethodLength
def Delegator.delegating_block_with_binding(mid) # :nodoc:
  lambda do |*args, &block|
    target = __getobj__
    send_block = if block
                   proc do |match|
                     block_binding = block.binding
                     block_binding.local_variable_set(:_turbotest_tilde, $LAST_MATCH_INFO)
                     block_binding.eval("$~=_turbotest_tilde")
                     block.call(match)
                   end
                 else
                   block
                 end
    result = target.__send__(mid, *args, &send_block)
    caller_binding = binding.of_caller(1)
    caller_binding.local_variable_set(:_turbotest_tilde, $LAST_MATCH_INFO)
    caller_binding.eval("$~=_turbotest_tilde")
    result
  end
end
# :nocov:

def Delegator.delegating_block_with_binding_ruby_27(mid) # :nodoc:
  lambda do |*args, &block|
    target = __getobj__
    send_block = if block
                   proc do |match|
                     block_binding = block.binding
                     block_binding.local_variable_set(:_turbotest_tilde, $LAST_MATCH_INFO)
                     block_binding.eval("$~=_turbotest_tilde")
                     block.call(match)
                   end
                 else
                   block
                 end
    result = target.__send__(mid, *args, &send_block)
    caller_binding = binding.of_caller(1)
    caller_binding.local_variable_set(:_turbotest_tilde, $LAST_MATCH_INFO)
    caller_binding.eval("$~=_turbotest_tilde")
    result
  end.ruby2_keywords
end
# rubocop:enable Metrics/MethodLength
