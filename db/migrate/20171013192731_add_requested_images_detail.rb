class AddRequestedImagesDetail < ActiveRecord::Migration
  def change
    add_column :digital_image_orders, :requested_images_detail, :text
  end
end
