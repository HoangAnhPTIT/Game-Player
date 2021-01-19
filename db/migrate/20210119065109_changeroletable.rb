class Changeroletable < ActiveRecord::Migration[6.1]
  def change
    remove_column :roles, :created_at, :timestamp
    remove_column :roles, :updated_at, :timestamp
  end
end
