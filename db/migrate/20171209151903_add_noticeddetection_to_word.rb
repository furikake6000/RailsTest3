class AddNoticeddetectionToWord < ActiveRecord::Migration[5.1]
  def change
    add_column :words, :noticed_detection, :boolean
  end
end
