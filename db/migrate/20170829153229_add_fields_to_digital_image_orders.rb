class AddFieldsToDigitalImageOrders < ActiveRecord::Migration
  def change
    add_column :digital_image_orders, :label, :string
    add_column :digital_image_orders, :uri, :string
    add_column :digital_image_orders, :requested_images, :text
  end
end
