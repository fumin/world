require 'active_record'
require 'uri'

def setup_db_conn
puts "!!!!!!!!!!!!!!!! #{ENV['DATABASE_URL']}, #{URI.parse(ENV['DATABASE_URL'])}, #{URI.methods.sort}"
  ActiveRecord::Base.establish_connection(
    ENV['DATABASE_URL'] ?
      ENV['DATABASE_URL'] :
      YAML::load(File.open('config/database.yml'))['development'])
end

def init_app
  setup_db_conn
  ActiveSupport::Dependencies.autoload_paths << 
    ::File.join(File.dirname(__FILE__), 'app/models')
end