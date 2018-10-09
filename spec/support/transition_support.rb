module TransitionSupport

  # excludes :order which happens automatically when order is confirmed
  def item_events
    [ :transfer, :receive_at_temporary_location, :prepare_at_temporary_location,
      :mark_for_return, :return, :receive_at_permanent_location ]
  end


  def item_events_to_ready
    [ :transfer, :receive_at_temporary_location, :prepare_at_temporary_location ]
  end


  def item_events_ready_to_finished
    [ :mark_for_return, :return, :receive_at_permanent_location ]
  end


  def order_events
    [ :review, :confirm, :fulfill, :close ]
  end


  def move_item_from_ready_to_finished(item, order, user)
    item_events_ready_to_finished.each do |event|
      item.trigger!(event, transition_metadata(user, order))
    end
  end


  def move_item_through_all_states(item, order, user)
    item_events.each do |event|
      item.trigger!(event, transition_metadata(user, order))
    end
  end


  def move_item_to_ready(item, order, user)
    item_events_to_ready.each do |event|
      item.trigger!(event, transition_metadata(user, order))
    end
  end


  def transition_metadata(user, order = nil)
    {
      user_id: user.id,
      order_id: order ? order.id : nil
    }
  end


end
