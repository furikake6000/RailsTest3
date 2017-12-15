class AddWordstrToReport < ActiveRecord::Migration[5.1]
  def change
    add_column :reports, :word_str, :string
  end
end
