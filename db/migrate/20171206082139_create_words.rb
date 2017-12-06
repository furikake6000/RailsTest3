class CreateWords < ActiveRecord::Migration[5.1]
  def change
    create_table :words do |t|
      t.string :name
      t.boolean :detected

      t.timestamps
    end
  end
end
