class AddWordupdatedToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :word_updated_at, :datetime
  end
end
