class RemoveDefaultFromLocations < ActiveRecord::Migration[5.2]
  def change
    remove_column :locations, :default
  end
end
