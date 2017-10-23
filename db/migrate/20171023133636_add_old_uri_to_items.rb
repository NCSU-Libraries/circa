class AddOldUriToItems < ActiveRecord::Migration

  def change
    add_column :items, :old_uri, :string
    Item.reset_column_information
    puts "updatating Item URIs..."
    Item.find_each { |i| i.update_attributes(old_uri: i.uri); print '.' }
  end

end
