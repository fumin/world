class CreateRoutes < ActiveRecord::Migration
  def up
    create_table :routes do |t|
      t.string :username, null: false
      t.string :password, null: false
      t.string :current_service_hash

      t.timestamps
    end
    add_index :routes, :username, :unique => true
  end

  def down
    drop_table :routes
  end
end
