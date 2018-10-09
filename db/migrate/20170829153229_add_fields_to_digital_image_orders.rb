class AddFieldsToDigitalImageOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :digital_image_orders, :label, :string
    add_column :digital_image_orders, :display_uri, :string
    add_column :digital_image_orders, :manifest_uri, :string
    add_column :digital_image_orders, :requested_images, :text
  end
end
