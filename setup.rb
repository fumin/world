require 'active_record'

def setup_db_conn
  if ENV['DATABASE_URL']
    db_env = URI.parse(ENV['DATABASE_URL'])
    db = {}
    db['adapter'] = (db.scheme == 'postgres' ? 'postgresql' : db.scheme)
    db['host'] = db.host
    db['port'] = db.port
    db['username'] = db.user
    db['password'] = db.password
    db['database'] = db.path[1..-1]
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
