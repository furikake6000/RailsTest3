class CreateQuests < ActiveRecord::Migration[5.1]
  def change
    create_table :quests do |t|
      t.string :type
      t.integer :last_follower
      t.integer :last_following
      t.references :user, foreign_key: true

      t.timestamps
    end
    add_index :quests, [:user_id, :created_at]
  end
end
