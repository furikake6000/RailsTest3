class CreateQuests < ActiveRecord::Migration[5.1]
  def change
    create_table :quests do |t|
<<<<<<< HEAD
      t.string :questtype
      t.integer :last_follower
      t.integer :last_following
=======
      t.string :type
      t.int :last_follower
      t.int :last_following
>>>>>>> d124feea3fc206fabf8201b7678e85406077b222

      t.timestamps
    end
  end
end
