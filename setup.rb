require 'active_record'

def setup_db_conn
  if ENV['DATABASE_URL']
    db_env = URI.parse(ENV['DATABASE_URL'])
    db = {}
    db['adapter'] = (db_env.scheme == 'postgres' ? 'postgresql' : db_env.scheme)
    db['host'] = db_env.host
    db['port'] = db_env.port
    db['username'] = db_env.user
    db['password'] = db_env.password
    db['database'] = db_env.path[1..-1]
    db['pool'] = 1000
    db['encoding'] = 'utf8'
  else
    db = YAML::load(File.open('config/database.yml'))['development']
  end
  ActiveRecord::Base.establish_connection(db)
end

def init_app
  setup_db_conn
  ActiveSupport::Dependencies.autoload_paths << 
    ::File.join(File.dirname(__FILE__), 'app/models')
end
