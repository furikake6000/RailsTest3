class AddCountcacheToWord < ActiveRecord::Migration[5.1]
  def change
    add_column :words, :countcache, :integer, default: 0
  end
end
