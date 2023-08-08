require 'sequel'
require 'sequel/extensions/migration'
require 'yaml'

db_config = YAML.load(File.read(File.expand_path("../../database.yml", __FILE__)))
env = ENV['RACK_ENV'] || 'development'
DB = Sequel.connect(db_config[env])