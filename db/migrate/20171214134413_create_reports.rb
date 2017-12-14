class CreateReports < ActiveRecord::Migration[5.1]
  def change
    create_table :reports do |t|
      t.boolean :succeed
      t.references :user, foreign_key: true
      t.references :word, foreign_key: true

      t.timestamps
    end
  end
end
