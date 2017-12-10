class AddCachedatToWord < ActiveRecord::Migration[5.1]
  def change
    add_column :words, :cached_at, :datetime
  end
end
