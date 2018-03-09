require 'active_support/concern'

module SolrDoc
  extend ActiveSupport::Concern
  include ActionView::Helpers::SanitizeHelper

  included do

    include GeneralUtilities

    after_commit :update_index, on: [:create, :update]

    def json_data(format=:json)

      record_attributes = lambda do |record|
        if record
          attrs = record.attributes
          if record.class == User
            allow = ['id', 'first_name', 'last_name', 'display_name', 'email', 'agreement_confirmed_at', 'created_at', 'updated_at', 'affiliation', 'position', 'patron_type_id', 'user_role_id']
            attrs.delete_if { |k,v| !allow.include? k }
          elsif record.class == AccessSession
            if attrs['start_datetime']
              attrs['start_datetime'] = attrs['start_datetime'].strftime('%FT%T%:z')
            end
            if attrs['end_datetime']
              attrs['end_datetime'] = attrs['end_datetime'].strftime('%FT%T%:z')
            end
          end
          if record.class == Order
            record.users.each do |u|
              (attrs['users'] ||= []) << record_attributes.call(u)
            end
            record.assignees.each do |a|
              (attrs['assignees'] ||= []) << record_attributes.call(a)
            end
          end
          attrs['created_at'] = attrs['created_at'].strftime('%FT%T%:z')
          attrs['updated_at'] = attrs['updated_at'].strftime('%FT%T%:z')
          return attrs
        end
      end

      data = record_attributes.call(self)

      case self
      when Item
        data[:current_state] = current_state
        if permanent_location
          data[:permanent_location] = record_attributes.call(permanent_location)
        end
        if current_location
          data[:current_location] = record_attributes.call(current_location)
        end
        if item_catalog_record
          data[:item_catalog_record] = record_attributes.call(item_catalog_record)
        end
        if active_access_session
          data[:active_access_session] = record_attributes.call(active_access_session)
          data[:active_access_session][:users] = active_access_session.users.to_a.map { |u| record_attributes.call(u) }
        end
        data[:has_open_orders] = has_open_orders?
        data[:open_order_ids] = open_orders.map { |o| o.id }
        data[:source] = source
        if last_accessed
          data[:last_accessed] = last_accessed.strftime('%FT%T%:z')
        end
        data[:active_order_id] = active_order_id
      when Order
        data[:current_state] = current_state
        if temporary_location
          data[:temporary_location] = record_attributes.call(temporary_location)
        end
        data[:num_items] = items.length
        data[:order_type] = order_type.attributes
        data[:order_type_id] = order_type.id
        data[:order_sub_type] = order_sub_type.attributes
        data[:primary_user] = record_attributes.call(primary_user)
        data[:active] = active?
        data[:num_items_ready] = num_items_ready
        data[:created_by_user] = record_attributes.call(created_by_user)
        data[:last_updated_by_user] = record_attributes.call(last_updated_by_user)
        data[:resource_ids] = items.map { |i| i.resource_identifier }.uniq
        data[:item_state] = items.map { |i| i.current_state }.uniq
        if course_reserve
          data[:course_name] = course_reserve.course_name
          data[:course_number] = course_reserve.course_number
        end
      when Location
        data[:source] = source
      when User
        data[:patron_type] = patron_type
        data[:roles] = roles
        data[:agreement_confirmed] = agreement_confirmed_at ? true : false
      end
      if format == :hash
        data
      else
        JSON.generate(data)
      end
    end


    # Prepare Solr document hash for the record
    def solr_doc_data
      doc = {
        id: solr_id,
        record_type: self.class.to_s.underscore,
        record_id: id,
        data: json_data,
        created_at: created_at,
        updated_at: updated_at
      }

      case self
      when Order
        [:open, :confirmed, :order_sub_type_id, :location_id].each do |attr|
          doc[attr] = self[attr]
        end

        if access_date_start
          doc[:access_date_start] = access_date_start.to_s
          doc[:access_date_end] = access_date_end ? access_date_end.to_s : access_date_start.to_s
        end

        doc[:state] = current_state

        if order_type
          doc[:order_type_id] = order_type.id
          doc[:order_type_label] = order_type.label
          doc[:order_type_name] = order_type.name
        end

        if order_sub_type
          doc[:order_sub_type_label] = order_sub_type.label
          doc[:order_sub_type_name] = order_sub_type.name
        end

        if temporary_location
          doc[:location] = temporary_location.title
        end

        if course_reserve
          doc[:course_name] = course_reserve.course_name
          doc[:course_number] = course_reserve.course_number
        end

        if items.length > 0
          doc[:item_id] = items.map { |i| i.id }
          doc[:resource_ids] = items.map { |i| i.resource_identifier }.uniq
          doc[:item_state] = items.map { |i| i.current_state }.uniq
        end

        if users.length > 0
          doc[:user_id] = users.map { |u| u.id }
          doc[:user_email] = users.map { |u| u.email }
          doc[:user_email_txt] = users.map { |u| u.email }
          doc[:user_first_name_txt] = users.map { |u| u.first_name }
          doc[:user_last_name_txt] = users.map { |u| u.last_name }
        end

        if assignees.length > 0
          doc[:assignee_id] = assignees.map { |a| a.id }
          doc[:assignee_email] = assignees.map { |a| a.email }
          doc[:assignee_email_txt] = assignees.map { |a| a.email }
          doc[:assignee_first_name_txt] = assignees.map { |a| a.first_name }
          doc[:assignee_last_name_txt] = assignees.map { |a| a.last_name }
        end

        if notes.length > 0
          doc[:notes] = notes.map { |n| n.content }
        end
      when Item
        [:resource_title, :resource_identifier, :resource_uri,
          :container, :uri, :permanent_location_id, :current_location_id, :digital_object, :unprocessed, :digital_object_title, :obsolete].each do |attr|
          doc[attr] = self[attr]
        end

        doc[:state] = current_state

        doc[:last_accessed] = last_accessed

        if current_location
          doc[:current_location] = current_location.title
        end

        if permanent_location
          doc[:permanent_location] = permanent_location.title
          doc[:permanent_location_facility] = permanent_location.facility
        else
          doc[:permanent_location_facility] = 'unknown'
        end

        if item_archivesspace_records.length > 0
          doc[:archivesspace_uri] = item_archivesspace_records.map { |x| x.archivesspace_uri }
        end

        if item_catalog_record
          doc[:catalog_record_id] = item_catalog_record.catalog_record_id
          doc[:catalog_item_id] = item_catalog_record.catalog_item_id
          doc[:call_number] = item_catalog_record.call_number
        end

        if has_open_orders?
          doc[:open_order_id] = open_orders.map { |o| o.id }
          doc[:next_scheduled_use_date] = next_scheduled_use_date
        end
      when User
        [:email, :affiliation, :first_name, :last_name, :role, :patron_type_id, :user_role_id].each do |attr|
          doc[attr] = self[attr]
        end
        doc[:agreement_confirmed] = !agreement_confirmed_at.nil?
        doc[:patron_type] = patron_type
        doc[:roles] = roles
      when Location
        doc[:title] = title
        doc[:source] = source
        doc[:source_id] = source_id
      end

      # remove nil/empty values
      doc.delete_if { |k,v| nil_or_empty?(v) }
      doc
    end

    def solr_id
      "#{ self.class.to_s.underscore }_#{ id }"
    end

    # Updates the record in the Solr index
    def update_index
      self.reload
      SearchIndex.update_record(self)
    end

    # Remove the record from the Solr index
    def delete_from_index
      SearchIndex.delete_record(self)
    end

  end

end
