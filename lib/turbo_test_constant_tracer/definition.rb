# frozen_string_literal: true

require "binding_of_caller"
require_relative "definition/templates"

module TurboTest
  module ConstantTracer
    module Definition
      class << self
        include DefinitionTemplates

        def internal_proxy(klass, name, constant, location)
          freeze = constant.frozen?
          constant = constant.dup if freeze
          create_internal_proxy_methods(constant, klass, name, location)
          constant.__turbo_test_tt_proxy_dup_object = constant.dup
          constant.__send__(:__turbo_test_freeze) if freeze
          set_class_constant(klass, name, constant)
        end

        def delegator_proxy(klass, name, constant, location)
          proxy_class = Constructor.new(constant.class).construct
          proxy_object = proxy_class.new(constant)
          proxy_object.turbo_test_name = "#{klass}::#{name}"
          proxy_object.turbo_test_path = location
          ProxyKlass.proxied_objects[proxy_object.object_id] = true
          set_class_constant(klass, name, proxy_object)
        end

        SPECIAL_METHODS = {
          "String" => %i[scan gsub gsub! sub sub!],
          "Enumerable" => %i[all? any? grep grep_v none? one? slice_before slice_after]
        }.freeze

        SUPER_SPECIAL_METHODS = {
          "String" => [:=~]
        }.freeze

        private

        def create_internal_proxy_methods(object, klass, name, location)
          singleton_class = object.singleton_class
          singleton_class.class_eval { attr_accessor :__turbo_test_tt_proxy_dup_object }

          methods_to_modify(object).each do |mod_method|
            alias_original_method(singleton_class, mod_method, mod_method)
            define_proxy_method(singleton_class, klass, mod_method, name, location)
          end

          modify_string_methods(object, klass, singleton_class, name, location)
          modify_enumerable_methods(object, klass, singleton_class, name, location)
        end

        def methods_to_modify(object)
          singleton_class = object.singleton_class
          mod_methods = singleton_class.instance_methods.reject do |method|
            method == :__send__
          end
          if object.class == ::String
            mod_methods -= SPECIAL_METHODS["String"]
            mod_methods -= SUPER_SPECIAL_METHODS["String"]
          end
          mod_methods -= SPECIAL_METHODS["Enumerable"] if object.is_a? ::Enumerable
          mod_methods
        end

        def modify_string_methods(object, klass, singleton_class, name, location)
          return unless object.class == ::String

          SPECIAL_METHODS["String"].each do |mod_method|
            original_method = mod_method
            mod_method = mod_method.to_s.gsub("!", "_bang").to_sym
            alias_original_method(singleton_class, mod_method, original_method)
            define_proxy_string_template_method(
              singleton_class, "#{klass}::#{name}", mod_method, location, original_method
            )
          end
          define_equal_tilde_method(singleton_class, klass, name, location)
        end

        def modify_enumerable_methods(object, klass, singleton_class, name, location)
          return unless object.is_a? ::Enumerable

          SPECIAL_METHODS["Enumerable"].each do |mod_method|
            original_method = mod_method
            mod_method = mod_method.to_s.gsub("?", "_question_mark").to_sym
            alias_original_method(singleton_class, mod_method, original_method)
            define_proxy_enumerable_template_method(
              singleton_class, "#{klass}::#{name}", location, original_method
            )
          end
        end
      end
    end
  end
end
