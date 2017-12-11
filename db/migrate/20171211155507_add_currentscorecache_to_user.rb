class AddCurrentscorecacheToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :current_score_cache, :integer
  end
end
