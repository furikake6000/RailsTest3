class CreateQuests < ActiveRecord::Migration[5.1]
  def change
    create_table :quests do |t|
      t.string :type
      t.string :last_follower
      t.string :last_following

      t.timestamps
    end
  end
end
