class Changetypeundo < ActiveRecord::Migration[6.1]
  def change
    change_column :logs, :undo, :integer
  end
end
