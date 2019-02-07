require 'active_support/concern'

module ItemStateConfig

  extend ActiveSupport::Concern

  included do

    # Specify state an item is in by default upon creation
    # (different for physical and digital items)
    def initial_state
      if self.digital_object
        :pending
      else
        :at_permanent_location
      end
    end


    # FOR PHYSICAL ITEMS
    # Define states, events to move to state, and description of the event displayed to users
    def self.states_events_physical
      [
        {
          event: :receive_at_permanent_location,
          to_state: :at_permanent_location,
          event_description: "Item has been received at its permanent location."
        },
        {
          event: :order,
          to_state: :ordered,
          event_description: "Request item for transfer to use location."
        },
        {
          event: :transfer,
          to_state: :in_transit_to_temporary_location,
          event_description: "Item is in transit to use location."
        },
        {
          event: :cancel_order,
          to_state: :at_permanent_location,
          event_description: "Move item from 'ordered' back to 'at permanent location'."
        },
        {
          event: :receive_at_temporary_location,
          to_state: :arrived_at_temporary_location,
          event_description: "Item has been received at its temporary (use) location."
        },
        {
          event: :prepare_at_temporary_location,
          to_state: :ready_at_temporary_location,
          event_description: "Item has been reviewed and is ready for use."
        },
        {
          event: :check_out,
          to_state: :in_use,
          event_description: "Check item out for active use."
        },
        {
          event: :check_in,
          to_state: :ready_at_temporary_location,
          event_description: "Item has been returned by the person actively using it."
        },
        {
          event: :mark_for_return,
          to_state: :to_return,
          event_description: "Item is ready to return to its permanent location."
        },
        {
          event: :return,
          to_state: :returning_to_permanent_location,
          event_description: "Mark item as in transit to its permanent location."
        },
        {
          event: :cancel_return,
          to_state: :ready_at_temporary_location,
          event_description: "Move item from 'to return' back to 'ready at temporary location'."
        },
        {
          event: :already_on_site,
          to_state: :ready_at_temporary_location,
          event_description: "Item is already available at its use location."
        },
        {
          event: :report_not_found,
          to_state: :not_found,
          event_description: "Item cannot be found or was not received as expected."
        },
        {
          event: :report_missing,
          to_state: :missing,
          event_description: "Item was reported not found and, upon searching for it, remains missing."
        },
        {
          event: :report_found,
          to_state: :found,
          event_description: "Item previously not found or missing has been located."
        }
      ]
    end


    # FOR DIGITAL ITEMS
    # Define states, events to move to state, and description of the event displayed to users
    def self.states_events_digital
      [
        {
          event: :reset,
          to_state: :pending,
          event_description: "Default state"
        },
        {
          event: :order,
          to_state: :ordered,
          event_description: "Forward request to Digital Program Librarian and curator"
        },
        {
          event: :review,
          to_state: :reviewing,
          event_description: "Review request and determine restrictions where applicable"
        },
        {
          event: :prepare_for_use,
          to_state: :preparing_for_use,
          event_description: "Copy files to laptop and prepare for use"
        },
        {
          event: :receive_at_use_location,
          to_state: :ready_at_use_location,
          event_description: "Receive laptop at use location"
        },
        {
          event: :check_out,
          to_state: :in_use,
          event_description: "Transfer laptop to researcher for use"
        },
        {
          event: :check_in,
          to_state: :ready_at_use_location,
          event_description: "Laptop has been returned to library custody"
        },
        {
          event: :prepare_for_return,
          to_state: :preparing_for_return,
          event_description: "Reset or refresh laptop as required"
        },
        {
          event: :cancel_return,
          to_state: :ready_at_use_location,
          event_description: "Move item from 'preparing for return' back to 'ready at use location'"
        },
        {
          event: :return,
          to_state: :use_complete,
          event_description: "Use of laptop is complete and it will be returned"
        }
      ]
    end


    # Define the final/terminal state for physical or digital Items
    def final_state
      digital_object ? :use_complete : :at_permanent_location
    end


    # Helper method to retried applicable state/event definitions for Item instance
    def self.states_events
      {
        physical: self.states_events_physical,
        digital: self.states_events_digital
      }
    end


    # Helper method to retried applicable state/event definitions for Item instance
    def states_events_config
      digital_object ? self.class.states_events_digital : self.class.states_events_physical
    end


    # Returns states/events as a flat array for use in the front end
    def states_events
      states_events_config.map { |se| [ se[:to_state], se[:event], se[:event_description] || '' ] }
    end


    # Returns completed state transitions for Item for a specific Order
    def state_transitions_for_order(order_id)
      StateTransition.where(record_id: id, record_type: self.class.to_s, order_id: order_id).order(id: :desc)
    end


    # Returns boolean to specify whether a given state has been reached for Item on a specific Order
    def state_reached_for_order(state, order_id)
      states = state_transitions_for_order(order_id).map { |t| t.to_state }
      states.include?(state.to_s)
    end


    def workflow_complete_for_order(order_id)
      state_reached_for_order(final_state, order_id)
    end


    # Override for Items and/or Orders as needed
    def required_metadata_present?(event, metadata)
      metadata[:order_id] && metadata[:user_id]
    end


    # FOR PHYSICAL ITEMS
    # Specifies conditions under which a given event is permitted
    # Returns boolean
    def event_permitted_physical(event)
      case event
      when :receive_at_permanent_location
        current_state == :returning_to_permanent_location
      when :order
        has_confirmed_order? && (current_state == :at_permanent_location)
      when :transfer
        current_state == :ordered
      when :cancel_order
        current_state == :ordered
      when :receive_at_temporary_location
        current_state == :in_transit_to_temporary_location
      when :prepare_at_temporary_location
        current_state == :arrived_at_temporary_location
      when :check_out
        current_state == :ready_at_temporary_location
      when :check_in
        current_state == :in_use
      when :mark_for_return
        current_state == :ready_at_temporary_location &&
          active_order_ids.length <= 1
      when :return
        current_state == :to_return
      when :cancel_return
        current_state == :to_return
      when :report_not_found
        ![:not_found, :missing, :found].include?(current_state)
      when :report_missing
        current_state == :not_found
      when :report_found
        [:missing, :not_found].include?(current_state)
      when :already_on_site
        has_confirmed_order?
      end
    end


    # FOR DIGITAL ITEMS
    # Specifies conditions under which a given event is permitted
    # Returns boolean
    def event_permitted_digital(event)
      case event
      when :order
        current_state == :pending
      when :review
        current_state == :ordered
      when :prepare_for_use
        current_state == :reviewing
      when :receive_at_use_location
        current_state == :preparing_for_use
      when :check_out
        current_state == :ready_at_use_location
      when :check_in
        current_state == :in_use
      when :prepare_for_return
        current_state == :ready_at_use_location
      when :return
        current_state == :preparing_for_return
      when :cancel_return
        current_state == :preparing_for_return
      when :receive
        current_state == :returning
      end
    end


    # Returns true if event is permitted for this Item
    # based on conditions defined in event_permitted_physical or event_permitted_digital
    def event_permitted(event)
      if obsolete
        false
      elsif self.digital_object
        event_permitted_digital(event)
      else
        event_permitted_physical(event)
      end
    end


    # Returns an array of events that are permitted for this item
    #   in the context of a given order
    def available_events_for_order(order_id)
      item_order = item_orders.where(order_id: order_id).first
      events = []
      if item_order && !obsolete
        order = item_order.order

        if (order.open || order.reproduction_order?) && order.confirmed && item_order.active
          events = available_events

          # remove :already_on_site if the item is already at the temporary location
          if events.include?(:already_on_site) && at_temporary_location_for_order?(order_id)
            events.delete(:already_on_site)
          end

          # items cannot be returned if they are active on multiple orders
          if events.include?(:mark_for_return) && active_order_ids.length > 1
            events.delete(:mark_for_return)
          end
        end
      end
      events
    end


    # Define methods to be executed AFTER the given even is complete
    #   and the Item moves to a new state
    def event_callbacks(event, metadata={})
      case event
      when :transfer, :return
        self.current_location_id = nil
        save!
        if self.digital_object
          close_applicable_orders(metadata)
        end
      when :receive_at_permanent_location, :receive
        self.current_location_id = permanent_location_id
        save!

        # deactivate other ItemOrders when Item is returned
        if metadata[:order_id]
          deactivate_for_other_orders(metadata[:order_id], metadata[:user_id])
          reload
        end
        close_applicable_orders(metadata)
      when :prepare_at_temporary_location, :receive_at_use_location
        open_orders.each do |o|
          o.fulfill_if_items_ready(metadata)
        end
      when :report_found
        reload
        previous_transition = last_transition_before(:not_found, :missing, :found)
        to_state = previous_transition ? previous_transition.to_state : self.initial_state
        found_transition = last_transition
        metadata = {
          user_id: found_transition.user_id,
          order_id: found_transition.order_id,
          location_id: found_transition.location_id
        }
        transition_to(to_state, metadata)
      when :already_on_site
        if metadata[:order_id]
          location_id = Order.where(id: metadata[:order_id]).pluck(:location_id).first
          update_attributes(current_location_id: location_id)
        end
        open_orders.each do |o|
          o.fulfill_if_items_ready(metadata)
        end
      end
    end


    # Force Item (physical) into :at_permanent_location state
    #   (effectively a reset)
    def force_return_to_permanent_location(metadata={})
      transition_to(:at_permanent_location, metadata)
      update_index
    end


    # Moves any open orders associated with the Item to the :closed state if applicable
    # This is a helper method used in even_callbacks above
    def close_applicable_orders(metadata={})
      open_orders.each do |o|
        if o.finished?
          o.trigger(:close, metadata)
        end
      end
    end


    def sort_available_events(events)
      if events.include?(:already_on_site)
        e = events.delete(:already_on_site)
        events.push(e)
      end
      events
    end

  end
end
