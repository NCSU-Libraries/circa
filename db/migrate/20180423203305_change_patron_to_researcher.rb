class ChangePatronToResearcher < ActiveRecord::Migration[5.2]
  def change
    rename_column :users, :patron_type_id, :researcher_type_id
  end
end
