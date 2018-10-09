class AddTotalImagesToDigitalImageOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :digital_image_orders, :total_images_in_resource, :integer
  end
end
