class Addgameidtmp < ActiveRecord::Migration[6.1]
  def change
    add_column :tmps, :gameid, :bigint
  end
end
