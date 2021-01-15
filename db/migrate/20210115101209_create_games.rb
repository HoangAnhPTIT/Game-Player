class CreateGames < ActiveRecord::Migration[6.1]
  def up 
    create_table :games do |t|
      # t.belongs_to :player

      t.timestamps
    end

    add_column :games, :player1, :bigint 
    add_column :games, :player2, :bigint
    add_column :games, :winner, :bigint
    add_column :games, :status, :boolean
    add_foreign_key :games, :players, column: :player1, primary_key: "id"
    add_foreign_key :games, :players, column: :player2, primary_key: "id"
  end


  def down 
    drop_table :games
  end
end
