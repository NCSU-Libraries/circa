require 'active_support/concern'

module OrderStateConfig

  extend ActiveSupport::Concern

  included do


    # Specify state an Order is in by default upon creation
    def initial_state
      :pending
    end


    # Define states, events to move to state, and description of the event displayed to users
    def self.states_events
      [
        {
          event: :reset,
          to_state: :pending,
          event_description: "Reset order status to 'pending'."
        },
        {
          event: :review,
          to_state: :reviewing,
          event_description: "Review the request prior to confirmation."
        },
        {
          event: :confirm,
          to_state: :confirmed,
          event_description: "The request has been reviewed and items are approved for transfer."
        },
        {
          event: :fulfill,
          to_state: :fulfilled,
          event_description: "All items have been received at their use location."
        },
        {
          event: :finish,
          to_state: :finished,
          event_description: "Use of the items is complete or no longer required. This order can be closed."
        }
      ]
    end


    # Special state/event definitions for reproduction requests
    def self.states_events_reproduction
      [
        {
          event: :reset,
          to_state: :pending,
          event_description: "Reset order status to 'pending'."
        },
        {
          event: :review,
          to_state: :reviewing,
          event_description: "Review the request prior to confirmation."
        },
        {
          event: :confirm,
          to_state: :confirmed,
          event_description: "The request has been reviewed and items are approved for transfer, digitization and/or delivery to the requester."
        },
        {
          event: :begin_work,
          to_state: :in_progress,
          event_description: "Digitization is in progress or files are being prepared for delivery.."
        },
        {
          event: :fulfill,
          to_state: :fulfilled,
          event_description: "Materials have been sent to the requester as specified."
        },
        {
          event: :finish,
          to_state: :finished,
          event_description: "All physical items have been returned and the requester has been invoiced as required. This order can be closed."
        }
      ]
    end


    # Define the final/terminal state for order
    def final_state
      :finished
    end


    # Instance method that calls self.states_events class method above
    # Provides common functionality between Items and Orders for shared methods in state_transition_support
    def states_events_config
      if self.order_type.name == 'reproduction'
        config = self.class.states_events_reproduction
      else
        config = self.class.states_events
      end
    end


    # Returns states/events as a flat array for use in the front end
    def states_events
      states_events_config.map { |se| [ se[:to_state], se[:event], se[:event_description] || '' ] }
    end


    # Define methods to be executed AFTER the given even is complete
    #   and the Order moves to a new state
    def event_callbacks(event, metadata={})
      case event
      when :reset, :review
        if confirmed
          update_attributes(confirmed: false)
        end
      when :confirm
        confirm
        # trigger :order for all applicable items
        # NOTE: :order event is common to both physical and digital items
        items.each do |i|
          if i.event_permitted(:order)
            user_id = last_transition.user_id
            i.trigger!(:order, { order_id: id, user_id: user_id })
          end
        end
      when :finish
        close
      end
      if event != :finish && !open
        reopen
      end
    end


    # Specifies conditions under which a given event is permitted
    # Returns boolean
    def event_permitted(event)
      case event
      when :review
        current_state == :pending
      when :confirm
        if !has_digital_items?
          [:pending, :reviewing].include? current_state
        else
          current_state == :reviewing
        end
      when :begin_work
        current_state == :confirmed
      when :fulfill
        if order_type.name == 'reproduction'
          [:confirmed, :in_progress].include? current_state
        else
          all_items_ready? && (current_state == :confirmed)
        end
      when :activate
        current_state == :fulfilled
      when :finish
        # current_state == :active
        (current_state == :fulfilled) && finished?
      end
    end


    # Returns integer representing the number of Items associated with this Order
    #   which are ready for use
    def num_items_ready
      ready = 0
      items.each do |i|
        if i.current_state == :ready_at_temporary_location
          ready += 1
        end
      end
      ready
    end


    # Returns true if all items associated with this Order are ready for use
    def all_items_ready?
      ready = false
      items.each do |i|
        if !i.obsolete
          if i.digital_object
            ready = i.state_reached_for_order(:ready_at_use_location, self.id)
          else
            ready = i.state_reached_for_order(:ready_at_temporary_location, self.id)
          end
        end
        break if !ready
      end
      ready
    end


    # Triggers the :fulfill event for this Order if all of its Items are ready for use
    def fulfill_if_items_ready(metadata)
      if available_events.include?(:fulfill) && all_items_ready?
        trigger(:fulfill, metadata)
      end
    end


    # Returns true if Order is finished
    def finished?
      finished = nil
      active_item_orders = item_orders.where(active: true)
      if state_reached?(:fulfilled)
        if active_item_orders.length == 0
          finished = true
        else
          active_item_orders.each do |io|
            i = io.item

            if !i.obsolete
              last_transition = i.state_transitions.where(order_id: id).first

              if last_transition && (last_transition.to_state == i.final_state.to_s)
                finished = true
              else
                finished = false
                break
              end
            end

          end
        end
      end
      finished
    end

  end
end
