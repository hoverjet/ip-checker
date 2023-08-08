require_relative 'boot'

namespace :db do
  desc "Run database migrations"
  task :migrate do
    puts "Migrating database for #{ENV['RACK_ENV']} environment..."
    Sequel::TimestampMigrator.run(DB, 'db/migrate')
    puts "Migrations complete"
  end
end