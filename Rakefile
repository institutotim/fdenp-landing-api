require File.expand_path('../application', __FILE__)

task :environment do
end

task :eager_load do
  Application.eager_load!
end

Application.load_tasks
# Knapsack.load_tasks if defined?(Knapsack)

Rake.load_rakefile 'active_record/railties/databases.rake'

# if ActiveRecord::Base.schema_format == :sql
#   Rake::Task['db:seed'].enhance(['environment', 'eager_load'])
#   Rake::Task['db:migrate'].enhance(['environment', 'eager_load'])
#
#   Rake::Task['db:schema:load'].clear.enhance(['environment']) do
#     Rake::Task['db:structure:load'].invoke
#   end
# end
