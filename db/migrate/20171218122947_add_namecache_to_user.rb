class AddNamecacheToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :screen_name, :string
    add_column :users, :name, :string
    add_column :users, :imgurl, :string
  end
end
