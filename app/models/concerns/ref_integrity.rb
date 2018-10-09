require 'active_support/concern'

module RefIntegrity
  extend ActiveSupport::Concern

  included do

    include CircaExceptions

    before_destroy :check_deletable, prepend: true
    # before_destroy :delete_from_index

    def deletable?
      deletable = true
      case self
      when User
        if self.orders.length > 0
          deletable = false
        end
      when Order
        if (self.items.length > 0) || self.state_reached?(:confirmed)
          deletable = false
        end
      when Item
        if (self.item_orders.length > 0) || (self.access_sessions.length > 0)
          deletable = false
        end
      when Location
        if self.permanent_items.length > 0 || self.current_items.length > 0
          deletable = false
        elsif self.orders.length > 0
          self.orders.each do |o|
            if !o.deletable?
              deletable = false
              break
            end
          end
        end
      when UserRole
        deletable = users.length == 0
      end
      deletable
    end


    protected


    def delete_associations
      case self
      when Item
        self.item_archivesspace_records.each { |iar| iar.destroy }
        if self.item_catalog_record
          self.item_catalog_record.destroy
        end
      end
    end

    def check_deletable
      if deletable?

        if respond_to?(:delete_from_index)
          delete_from_index
          delete_associations
        end

      else
        error_messages = lambda do |type|
          case type
          when :user
            return "The user cannot be deleted because it is currently associated with one or more orders."
          when :order
            return "Confirmed orders cannot be deleted."
          when :item
            return "This item cannot be deleted because it associated with one or more orders or has an access history that must be maintained."
          when :location
            return "This location cannot be deleted because it is associated with one or more items or orders."
          when :user_role
            return "This user role cannot be deleted because it has associated users."
          end
        end
        puts error_messages.call(self.class.to_s.underscore.to_sym)
        raise CircaExceptions::ReferentialIntegrityConflict, error_messages.call(self.class.to_s.downcase.to_sym)
        false
      end
    end

  end
end
