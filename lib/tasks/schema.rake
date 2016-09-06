require "prmd/rake_tasks/combine"
require "prmd/rake_tasks/verify"
require "prmd/rake_tasks/doc"

namespace :schema do
  Prmd::RakeTasks::Combine.new do |t|
    t.options[:meta] = 'schema/meta.json'
    t.paths << 'schema/schemata'
    t.output_file = 'schema/unicef-api.json'
  end

  Prmd::RakeTasks::Verify.new do |t|
    t.files << 'schema/unicef-api.json'
  end

  Prmd::RakeTasks::Doc.new do |t|
    t.files = { 'schema/unicef-api.json' => 'schema/unicef-api.md' }
  end

  task default: ["schema:combine", "schema:verify", "schema:doc"]
end
