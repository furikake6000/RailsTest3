class AddParametersToQuest < ActiveRecord::Migration[5.1]
  def change
    add_column :quests, :value, :integer
    add_column :quests, :target, :string
  end
end
