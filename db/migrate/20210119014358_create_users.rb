class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :fullname
      t.string :password
      t.string :username
      t.bigint :roleid
      t.timestamps
    end
    add_foreign_key :users, :roles, column: :roleid, primary_key: 'id'
  end
  def down
    drop_table :users
  end
end
