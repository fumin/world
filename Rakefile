require 'logger'
require './setup'

namespace :db do
  desc "Setup environment"
  task(:environment) do
    setup_db_conn
  end

  desc "Create database"
  task(:create) do
    cfg = db_hash
    ActiveRecord::Base.establish_connection(
      cfg.merge('database' => 'postgres'))
    ActiveRecord::Base.connection.create_database(cfg['database'])
  end

  desc "Drop database"
  task(:drop) do
    cfg = db_hash
    ActiveRecord::Base.establish_connection(
      cfg.merge('database' => 'postgres'))
    ActiveRecord::Base.connection.drop_database(cfg['database'])
  end

  desc "Migrate the database"
  task(migrate: :environment) do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.migrate("db/migrate")
  end

  desc "Rollback migration"
  task(rollback: :environment) do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Migration.verbose = true
    step = ENV['STEP'] ? ENV['STEP'].to_i : 1
    ActiveRecord::Migrator.rollback("db/migrate", step)
  end

end
