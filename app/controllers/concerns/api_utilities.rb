require 'active_support/concern'

module ApiUtilities
  extend ActiveSupport::Concern

  included do

    include CircaExceptions
    include StateTransitionSupport

    rescue_from ActiveRecord::RecordNotFound, with: :not_found
    rescue_from CircaExceptions::BadRequest, with: :bad_request
    rescue_from ActiveRecord::RecordInvalid, with: :validation_error
    rescue_from CircaExceptions::Forbidden, with: :admin_only
    rescue_from StateTransitionException::TransitionNotPermitted, with: :bad_request
    rescue_from ActiveRecord::RecordNotDestroyed, with: :cannot_delete
    rescue_from CircaExceptions::ReferentialIntegrityConflict, with: :cannot_delete

    def destroy
      case params[:controller]
      when 'users'
        @record = User.find params[:id]
      when 'orders'
        @record = Order.find params[:id]
        if !@record.deletable?
          raise ActiveRecord::RecordInvalid("This order cannot be deleted")
        end
      when 'items'
        @record = Item.find params[:id]
      when 'locations'
        @record = Location.find params[:id]
      end

      if @record.destroy!
        render json: {}, status: 200
      end
    end


    private

    def not_found(exception)
      render json: { error: { status: 404, detail: exception.message } }, status: 404
    end


    def bad_request(exception)
      detail = "Bad request"
      detail += exception.message ? ": #{exception.message}" : ''
      render json: { error: { detail: detail, status: 400 } }, status: 400
    end


    def validation_error(exception)
      detail = 'Validation error: '
      detail += exception.message ? ": #{exception.message}" : ''
      render json: { error: { detail: detail, status: 500 } }, status: 500
    end


    def admin_only(exception)
      render json: { error: { status: 403, detail: "Forbidden: This action is only available to administrators." } }, status: 403
    end


    def cannot_delete(exception)
      render json: { error: { status: 403, detail: exception.message } }, status: 403
    end


    # Note: event must be a symbol, not a string (as it is in params[:event])
    def trigger_event(record, event, metadata = {})
      metadata[:user_id] = current_user.id
      metadata[:request] = request
      if record.permitted_events.include?(event.to_sym) || current_user.is_admin?
        record.trigger!(event, metadata)
        render json: record
        return
      else
        render json: { error: { status: 403, detail: 'State transition not permitted' } }, status: 403
        return
      end

    end


    def pagination_params
      {
        page: @page.to_i,
        per_page: @per_page.to_i,
        total: @total.to_i,
        pages: @pages.to_i,
        sort: @sort,
        filter: @filter
      }
    end


    def check_values(value_type, values)
      pass = false
      case value_type
      when :archivesspace_archival_object_uri
        validate = lambda do |value|
          return value.match(/^\/repositories\/\d+\/archival_objects\/\d+$/)
        end
      when :archivesspace_location_uri
        validate = lambda do |value|
          return value.match(/^\/locations\/\d+$/)
        end
      when :email
        validate = lambda do |value|
          return value.match(/^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i)
        end
      end
      values.each do |v|
        if !validate.call(v)
          pass = false
          break
        else
          pass = true
        end
      end
      pass
    end



    def admin_only
      if !current_user.is_admin?
        render json: { error: { detail: "Forbidden: This operation is only available to admin users.", status: 403 } }, status: 403
      end
    end


    def exception_response(exception)
      Rails.logger.info exception.message; puts exception.message
      Rails.logger.info exception.backtrace.join("\n"); puts exception.backtrace.join("\n")
      render json: { error: { detail: "Internal server error: #{exception.message}" }, status: 500 }, status: 500
    end


  end

end
