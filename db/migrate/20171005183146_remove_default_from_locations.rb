class RemoveDefaultFromLocations < ActiveRecord::Migration
  def change
    remove_column :locations, :default
  end
end
