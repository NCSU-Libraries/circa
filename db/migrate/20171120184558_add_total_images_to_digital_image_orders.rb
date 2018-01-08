class AddTotalImagesToDigitalImageOrders < ActiveRecord::Migration
  def change
    add_column :digital_image_orders, :total_images_in_resource, :integer
  end
end
