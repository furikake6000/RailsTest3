class AddTodayscoreToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :todayscore, :integer
    remove_index :users, column: :score
    add_index :users, :current_score_cache
    add_index :users, :todayscore
  end
end
