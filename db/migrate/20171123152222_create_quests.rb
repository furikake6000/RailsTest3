class CreateQuests < ActiveRecord::Migration[5.1]
  def change
    create_table :quests do |t|
      t.string :type
      t.integer :last_follower
      t.integer :last_following

      t.timestamps
    end
  end
end
