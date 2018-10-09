require 'active_support/concern'

module SolrDoc
  extend ActiveSupport::Concern
  include ActionView::Helpers::SanitizeHelper

  included do

    include GeneralUtilities

    after_commit :update_index, on: [:create, :update]

    def json_data(format=:json)

      data = json_data_record_attributes(self)

      case self
      when Item
        data.merge!(item_json_data)
      when Order
        data.merge!(order_json_data)
      when Location
        data.merge!(location_json_data)
      when User
        data.merge!(user_json_data)
      end

      if format == :hash
        data
      else
        JSON.generate(data)
      end
    end

    #
    def item_json_data
      data = {}
      data[:current_state] = current_state
      if permanent_location
        data[:permanent_location] = json_data_record_attributes(permanent_location)
      end
      if current_location
        data[:current_location] = json_data_record_attributes(current_location)
      end
      if item_catalog_record
        data[:item_catalog_record] = json_data_record_attributes(item_catalog_record)
      end
      if active_access_session
        data[:active_access_session] = json_data_record_attributes(active_access_session)
        data[:active_access_session][:users] = active_access_session.users.to_a.map { |u| json_data_record_attributes(u) }
      end
      data[:has_open_orders] = has_open_orders?
      data[:open_order_ids] = open_orders.map { |o| o.id }
      data[:source] = source
      if last_accessed
        data[:last_accessed] = last_accessed.strftime('%FT%T%:z')
      end
      data[:active_order_id] = active_order_id
      data
    end

    #
    def order_json_data
      data = {}
      data[:current_state] = current_state
      if temporary_location
        data[:temporary_location] = json_data_record_attributes(temporary_location)
      end
      data[:num_items] = items.length
      data[:order_type] = order_type.attributes
      data[:order_type_id] = order_type.id
      data[:order_sub_type] = order_sub_type.attributes
      data[:primary_user] = json_data_record_attributes(primary_user)
      data[:active] = active?
      data[:num_items_ready] = num_items_ready
      data[:created_by_user] = json_data_record_attributes(created_by_user)
      data[:last_updated_by_user] = json_data_record_attributes(last_updated_by_user)
      data[:resource_ids] = items.map { |i| i.resource_identifier }.uniq
      data[:item_state] = items.map { |i| i.current_state }.uniq
      if course_reserve
        data[:course_name] = course_reserve.course_name
        data[:course_number] = course_reserve.course_number
      end
      data
    end

    def location_json_data
      data = {}
      data[:source] = source
      data
    end

    def user_json_data
      data = {}
      data[:researcher_type] = researcher_type
      data[:roles] = roles
      data[:agreement_confirmed] = agreement_confirmed_at ? true : false
      data
    end

    # Prepare Solr document hash for the record
    def solr_doc_data
      @doc = {
        id: solr_id,
        record_type: self.class.to_s.underscore,
        record_id: id,
        data: json_data,
        created_at: created_at,
        updated_at: updated_at
      }

      case self
      when Order
        add_order_data_to_solr_doc
      when Item
        add_item_data_to_solr_doc
      when User
        add_user_data_to_solr_doc
      when Location
        add_location_data_to_solr_doc
      end

      # remove nil/empty values
      @doc.delete_if { |k,v| nil_or_empty?(v) }
      @doc
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


    private

    def add_order_data_to_solr_doc
      [:open, :confirmed, :order_sub_type_id, :location_id].each do |attr|
        @doc[attr] = self[attr]
      end

      if access_date_start
        @doc[:access_date_start] = access_date_start.to_s
        @doc[:access_date_end] = access_date_end ? access_date_end.to_s : access_date_start.to_s
      end

      @doc[:state] = current_state

      if order_type
        @doc[:order_type_id] = order_type.id
        @doc[:order_type_label] = order_type.label
        @doc[:order_type_name] = order_type.name
      end

      if order_sub_type
        @doc[:order_sub_type_label] = order_sub_type.label
        @doc[:order_sub_type_name] = order_sub_type.name
      end

      if temporary_location
        @doc[:location] = temporary_location.title
      end

      if course_reserve
        @doc[:course_name] = course_reserve.course_name
        @doc[:course_number] = course_reserve.course_number
      end

      if items.length > 0
        @doc[:item_id] = items.map { |i| i.id }
        @doc[:resource_ids] = items.map { |i| i.resource_identifier }.uniq
        @doc[:item_state] = items.map { |i| i.current_state }.uniq
      end

      if users.length > 0
        @doc[:user_id] = users.map { |u| u.id }
        @doc[:user_email] = users.map { |u| u.email }
        @doc[:user_email_txt] = users.map { |u| u.email }
        @doc[:user_first_name_txt] = users.map { |u| u.first_name }
        @doc[:user_last_name_txt] = users.map { |u| u.last_name }
      end

      if assignees.length > 0
        @doc[:assignee_id] = assignees.map { |a| a.id }
        @doc[:assignee_email] = assignees.map { |a| a.email }
        @doc[:assignee_email_txt] = assignees.map { |a| a.email }
        @doc[:assignee_first_name_txt] = assignees.map { |a| a.first_name }
        @doc[:assignee_last_name_txt] = assignees.map { |a| a.last_name }
      end

      if notes.length > 0
        @doc[:notes] = notes.map { |n| n.content }
      end
    end

    def add_item_data_to_solr_doc
      [:resource_title, :resource_identifier, :resource_uri,
        :container, :uri, :permanent_location_id, :current_location_id, :digital_object, :unprocessed, :digital_object_title, :obsolete].each do |attr|
        @doc[attr] = self[attr]
      end

      @doc[:state] = current_state

      @doc[:last_accessed] = last_accessed

      if current_location
        @doc[:current_location] = current_location.title
      end

      if permanent_location
        @doc[:permanent_location] = permanent_location.title
        @doc[:permanent_location_facility] = permanent_location.facility
      else
        @doc[:permanent_location_facility] = 'unknown'
      end

      if item_archivesspace_records.length > 0
        @doc[:archivesspace_uri] = item_archivesspace_records.map { |x| x.archivesspace_uri }
      end

      if item_catalog_record
        @doc[:catalog_record_id] = item_catalog_record.catalog_record_id
        @doc[:catalog_item_id] = item_catalog_record.catalog_item_id
        @doc[:call_number] = item_catalog_record.call_number
      end

      if has_open_orders?
        @doc[:open_order_id] = open_orders.map { |o| o.id }
        @doc[:next_scheduled_use_date] = next_scheduled_use_date
      end
    end

    def add_user_data_to_solr_doc
      [:email, :affiliation, :first_name, :last_name, :display_name, :role, :researcher_type_id, :user_role_id].each do |attr|
        @doc[attr] = self[attr]
      end
      @doc[:agreement_confirmed] = !agreement_confirmed_at.nil?
      @doc[:researcher_type] = researcher_type
      @doc[:roles] = roles
    end

    def add_location_data_to_solr_doc
      @doc[:title] = title
      @doc[:source] = source
      @doc[:source_id] = source_id
    end

    #
    def json_data_record_attributes(record)
      if record
        attrs = record.attributes
        if record.class == User
          allow = [ 'id', 'first_name', 'last_name', 'display_name', 'email',
              'agreement_confirmed_at', 'created_at', 'updated_at',
              'affiliation', 'position', 'researcher_type_id', 'user_role_id']
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
            (attrs['users'] ||= []) << json_data_record_attributes(u)
          end
          record.assignees.each do |a|
            (attrs['assignees'] ||= []) << json_data_record_attributes(a)
          end
        end
        attrs['created_at'] = attrs['created_at'].strftime('%FT%T%:z')
        attrs['updated_at'] = attrs['updated_at'].strftime('%FT%T%:z')
        attrs
      end
    end
  end

end
