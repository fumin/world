require 'logger'
require './setup'

namespace :db do
  desc "Setup environment"
  task(:environment) do
    setup_db_conn
  end

  desc "Create database"
  task(:create) do
    cfg = YAML::load(File.open('config/database.yml'))['development']
    ActiveRecord::Base.establish_connection(
      cfg.merge('database' => 'postgres'))
    ActiveRecord::Base.connection.create_database(cfg['database'])
  end

  desc "Migrate the database"
  task(migrate: :environment) do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.migrate("db/migrate")
  end
end
