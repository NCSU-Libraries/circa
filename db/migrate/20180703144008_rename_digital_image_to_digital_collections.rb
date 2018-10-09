class RenameDigitalImageToDigitalCollections < ActiveRecord::Migration[5.2]
  def up
    rename_table :digital_image_orders, :digital_collections_orders
  end

  def down
    rename_table :digital_collections_orders, :digital_image_orders
  end
end
