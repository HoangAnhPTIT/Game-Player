class CreateLogs < ActiveRecord::Migration[6.1]
  def up
    create_table :logs do |t|
      t.integer :point1
      t.integer :point2

      t.datetime :timeplay
      t.timestamps
    end
    add_column :logs, :gameid, :bigint
    add_column :logs, :status, :boolean
    add_foreign_key :logs, :games, column: :gameid, primary_key: "id"
  end

  def down
    drop_table :logs
  end
end
