class AddRequestedImagesDetail < ActiveRecord::Migration[5.2]
  def change
    add_column :digital_image_orders, :requested_images_detail, :text
  end
end
