# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

if RUBY_VERSION >= "2.7"
  require "simplecov"
  SimpleCov.start do
    add_filter "/test/"
    enable_coverage :branch unless ENV["CI"]
    minimum_coverage line: 100, branch: 100 unless ENV["CI"]
  end
end

require "turbo_test_constant_tracer"
require "minitest/autorun"
require "mocha/minitest"
require "byebug"

class Minitest::Spec
  before do
    FileUtils.mkdir_p "tmp"
    remove_proxy_classes
  end

  after do
    FileUtils.rm_rf "tmp"
    remove_proxy_classes
  end

  private

  def remove_proxy_classes
    proxy_klass_desdendants.each do |descendant|
      TurboTest.send(:remove_const, descendant)
    end
  end

  def proxy_klass_desdendants
    ObjectSpace.each_object(TurboTest::ConstantTracer::ProxyKlass).each_with_object([]) do |klass, memo|
      next if klass.singleton_class?

      memo.unshift klass unless klass == self
    end
  end
end

module Minitest::Spec::DSL
  alias test it
end

require_relative "helpers/define_class"
require_relative "helpers/event_subscriber"
require_relative "helpers/string_helper"
require_relative "helpers/regexp_helper"
require_relative "helpers/enumerable_helper"
require_relative "helpers/delegated_test_setup"
