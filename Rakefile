# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"
require "rake/extensiontask"

ENV["TESTOPTS"] = "#{ENV['TESTOPTS']} --verbose"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

task default: :test

Rake::ExtensionTask.new "hash_lookup_with_proxy_ext" do |ext|
  ext.lib_dir = "lib"
end

if ENV["CI"]
  require "coveralls/rake/task"
  Coveralls::RakeTask.new
end
