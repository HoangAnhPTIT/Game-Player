class CreatePlayers < ActiveRecord::Migration[6.1]
  def up
    create_table :players do |t|
      t.string :fullname
      t.string :username
      t.string :password
      t.bigint :point
      t.integer :wincount
      t.integer :losecount
      t.boolean :status
      
      t.timestamps
    end
    # add_reference(:players, :player, index: true)

  end

  def down 
    drop_table :players
  end
end
