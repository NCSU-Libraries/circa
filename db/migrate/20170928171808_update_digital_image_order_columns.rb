class UpdateDigitalImageOrderColumns < ActiveRecord::Migration
  def change
    rename_column :digital_image_orders, :image_id, :resource_identifier
    rename_column :digital_image_orders, :label, :resource_title
  end
end
