require "bundler/setup"
require "rubocop/rake_task"
require "foodcritic"

FoodCritic::Rake::LintTask.new(:foodcritic)

desc "Run rubocop linter"
Rubocop::RakeTask.new(:rubocop) do |task|
  task.formatters = %w(simple)
end

desc "for travis-ci run"
task travis: :default

task lint: [:rubocop, :foodcritic]

task default: :lint
