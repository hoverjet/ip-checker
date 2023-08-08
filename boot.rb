require 'grape'
require 'grape-entity'
require 'zeitwerk'

Dir["#{__dir__}/config/initializers/*.rb"].each { |file| require_relative file }

loader = Zeitwerk::Loader.new
%w[models api workers services].each do |subdir|
  loader.push_dir("#{__dir__}/app/#{subdir}")
end
loader.setup
