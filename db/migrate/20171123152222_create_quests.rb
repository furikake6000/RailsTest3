class CreateQuests < ActiveRecord::Migration[5.1]
  def change
    create_table :quests do |t|
      t.string :type
      t.int :last_follower
      t.int :last_following

      t.timestamps
    end
  end
end
