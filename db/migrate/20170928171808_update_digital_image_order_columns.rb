class UpdateDigitalImageOrderColumns < ActiveRecord::Migration[5.2]
  def change
    rename_column :digital_image_orders, :image_id, :resource_identifier
    rename_column :digital_image_orders, :label, :resource_title
  end
end
