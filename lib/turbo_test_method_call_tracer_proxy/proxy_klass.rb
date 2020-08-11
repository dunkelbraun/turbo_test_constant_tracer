# frozen_string_literal: true

module TurboTest
  module MethodCallTracerProxy
    module ProxyKlass
      def self.proxied_objects
        @proxied_objects ||= {}
      end
    end
  end
end
