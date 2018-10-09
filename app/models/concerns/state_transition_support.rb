require 'active_support/concern'

module StateTransitionSupport

  extend ActiveSupport::Concern

  included do

    # self.states_events, self.initial_state, self.event_callbacks, states_events_config and event_permitted must be specified for model in app/models/concerns/[model_name]_state_config.rb

    # Returns hash of state/event pairs with event as key and state as value
    def self.to_states_by_event
      to_states = {}
      self.states_events.each { |se| to_states[se[:event]] = se[:to_state] }
      to_states
    end

    # returns "to" state associated with event
    def self.event_to_state(event)
      self.to_states_by_event[event]
    end

    # Returns array of permitted events
    def permitted_events
      events = self.states_events_config.map { |se| se[:event] }
      events.delete_if { |e| !event_permitted(e) }
    end

    # Returns array of available events
    def available_events
      events = permitted_events
      if respond_to?(:sort_available_events)
        events = sort_available_events(events)
      end
      events
    end

    # Returns state to which given event will transition the record
    def event_to_state(event)
      to_states = {}
      self.states_events_config.each { |se| to_states[se[:event]] = se[:to_state] }
      to_states[event]
    end


    # Triggers an event, moving record to associated state, if permitted
    # Returns false if event not permitted
    def trigger(event, metadata={})
      if (event_permitted(event) || User.is_admin?(metadata[:user_id])) &&
          required_metadata_present?(event, metadata)
        to_state = self.event_to_state(event)
        callback_metadata = metadata.clone
        transition_to(to_state, metadata)
        if respond_to?(:event_callbacks)
          event_callbacks(event, callback_metadata)
          reload
        end
        update_index
        true
      else
        false
      end
    end

    # Triggers an event, moving record to associated state, if permitted
    # Raises exception if event is not permitted
    def trigger!(event, metadata={})
      if !trigger(event, metadata)
        raise StateTransitionException::TransitionNotPermitted
      end
    end

    # Return all prior state transitions for the record
    def state_transitions
      StateTransition.where(record_id: id, record_type: self.class.to_s).order(id: :desc)
    end

    # Returns the last (most recent) state transition for the record
    def last_transition
      StateTransition.where(record_id: id, record_type: self.class.to_s).order(id: :desc).limit(1).first
    end

    # Returns the last (most recent) state transition that moved the record to the given state
    def last_transition_to(to_state)
      StateTransition.where(record_id: id, record_type: self.class.to_s, to_state: to_state.to_s).order(id: :desc).limit(1).first
    end

    # Returns the last state transition prior to the record moving to the given state
    def last_transition_before(*to_state)
      not_in_fragment = "'#{to_state.map { |x| x.to_s }.join("','")}'"
      StateTransition.where(record_id: id, record_type: self.class.to_s).where("to_state NOT IN (#{ not_in_fragment })").order(id: :desc).limit(1).first
    end

    # Returns the record's current state
    def current_state
      current = StateTransition.where(record_id: id, record_type: self.class.to_s, current: true).order(id: :desc).limit(1).first
      if current
        current.to_state.to_sym
      else
        self.initial_state.to_sym
      end
    end

    # Returns true if the current state is at or after the given state in the workflow
    def state_reached?(state)
      states = states_events.map { |se| se[0] }
      if states.index(current_state) && states.index(state)
        states.index(current_state) >= states.index(state)
      end
    end

    # Transition record to given state, creating a new StateTransition record
    def transition_to(to_state, metadata={})
      if last_transition
        last_transition.update_attributes(current: false)
      end
      from_state = last_transition ? last_transition.to_state : nil
      # remove request if included in metadata
      if metadata && metadata[:request]
        metadata.delete(:request)
      end
      attributes = {
        record_id: id,
        record_type: self.class.to_s,
        from_state: from_state,
        to_state: to_state.to_s,
        user_id: metadata[:user_id],
        location_id: metadata[:location_id],
        order_id: metadata[:order_id],
        metadata: metadata,
        current: true
      }
      StateTransition.create!(attributes)
    end

  end
end


module StateTransitionException
  class TransitionNotPermitted < StandardError; end
end
