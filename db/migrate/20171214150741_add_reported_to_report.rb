class AddReportedToReport < ActiveRecord::Migration[5.1]
  def change
    add_column :reports, :reported_id, :integer
  end
end
