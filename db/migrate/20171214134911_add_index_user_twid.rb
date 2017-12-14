class AddIndexUserTwid < ActiveRecord::Migration[5.1]
  def change
    add_index :users, :twid, unique: true
    add_index :users, :score
  end
end
