class Addroleplayer < ActiveRecord::Migration[6.1]
  def change
    add_column :players, :roleid, :bigint
    add_foreign_key :players, :roles, column: :roleid, primary_key: 'id'
  end
end
