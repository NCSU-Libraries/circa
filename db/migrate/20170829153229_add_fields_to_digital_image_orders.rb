class AddFieldsToDigitalImageOrders < ActiveRecord::Migration
  def change
    add_column :digital_image_orders, :manifest, 'longtext'
    add_column :digital_image_orders, :requested_images, :text
  end
end
