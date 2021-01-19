class Createtmptable < ActiveRecord::Migration[6.1]
  def change
    create_table :tmps do |t|
      t.integer :point1
      t.integer :point2
      t.bigint :logid
    end
    add_foreign_key :tmps, :logs, column: :logid, primary_key: 'id'
    add_column :logs, :undo, :boolean
  end
end
