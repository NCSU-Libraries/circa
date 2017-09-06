class ItemOrder < ActiveRecord::Base

  belongs_to :item
  belongs_to :order
  belongs_to :user
  has_one :order_fee, as: :record
  has_one :reproduction_spec

  validates :item_id, uniqueness: {scope: :order_id}

  serialize(:archivesspace_uri, Array)

  after_commit :update_index

  before_destroy :reset_item

  before_create :set_active

  def add_archivesspace_uri(uri)
    if !archivesspace_uri.include?(uri)
      archivesspace_uri << uri
      archivesspace_uri.uniq!
      save!
    end
  end


  # Update items from
  # Returns:
  #
  def update_archivesspace_item
    return_items = []
    if archivesspace_uri && !archivesspace_uri.empty?
      archivesspace_uri.each do |uri|
        new_items = Item.create_or_update_from_archivesspace(uri)

        if new_items && !new_items.empty?
          new_items.each_index do |i|
            new_item = new_items[i]

            return_items << new_item

            # create new items for any new returned
            if new_item != self.item
              params = { item_id: new_item.id, order_id: self.order_id, archivesspace_uri: self.archivesspace_uri }
              if !ItemOrder.where(params).exists?
                ItemOrder.create(params)
              end
            end

          end
        end
      end
    end
    return_items
  end


  def activate
    update_attributes(active: true)
  end


  def deactivate
    update_attributes(active: false)
  end


  private


  def set_active
    self.active = true
  end


  def update_index
    order.update_index
    item.update_index
  end


  def reset_item(metadata={})
    at_permanent_location = (item.current_location_id == item.permanent_location_id)
    if at_permanent_location && active
      item.force_return_to_permanent_location(metadata)
    end
  end


  def check_active
    existing_active = ItemOrder.where(item_id: item_id, active: true).first
    if !existing_active
      self.active = true
    end
  end

end
