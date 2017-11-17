class EnumerationValuesController < ApplicationController

  before_action :set_enumeration_value, only: [ :show, :update, :destroy ]

  def index
    @params = params
    render json: enumeration_values_response
  end


  def show
    render json: @enumeration_value
  end


  def create
    @params = params

    if params[:enumeration_name] && !params[:enumeration_id]
      enumeration = Enumeration.find_by_name(params[:enumeration_name])
      params[:enumeration_value][:enumeration_id] = enumeration.id
    end

    enumeration_id = params[:enumeration_value][:enumeration_id]
    last_order_value = EnumerationValue.where(enumeration_id: enumeration_id).order(:order).pluck(:order).last || 0
    params[:enumeration_value][:order] = last_order_value + 1

    if params[:enumeration_value][:value] && params[:enumeration_value][:value_short].blank?
      value_short = params[:enumeration_value][:value].downcase.gsub(/[^A-Za-z0-1_]/, '_').gsub(/_{2,}/,'_').gsub(/_$/,'')
      params[:enumeration_value][:value_short] = value_short
    end
    @enumeration_value = EnumerationValue.create!(enumeration_value_params)
    render json: @enumeration_value
  end


  def update
    @params = params
    @enumeration_value.update_attributes(enumeration_value_params)
    render json: @enumeration_value
  end


  def update_order
    @params = params
    if !params[:enumeration_values]
      raise CircaExceptions::BadRequest, "Order was not set due to an error."
    else
      params[:enumeration_values].each_index do |i|
        ev = params[:enumeration_values][i]
        enumeration_value = EnumerationValue.find(ev['id'])
        enumeration_value.update_attributes(order: i)
      end
    end
    render json: enumeration_values_response
  end


  def merge
    @merge_from_id = params[:merge_from_id]
    @merge_into_id = params[:merge_into_id]
    @enumeration_name = params[:enumeration_name]
    Enumeration.merge_values(@merge_from_id, @merge_into_id, @enumeration_name)
    @values = Enumeration.values_by_enumeration_name(@enumeration_name)
    render json: @values
  end


  def destroy
    @params = params
    if !@enumeration_value.deletable?
      raise CircaExceptions::ReferentialIntegrityConflict, "The enumeration value cannot be deleted due to a referential integrity conflict"
    else
      @enumeration_value.destroy
      render json: {}
    end
  end


  private


  def enumeration_value_params
    params.require(:enumeration_value).permit(:enumeration_id, :value, :value_short, :order)
  end


  def set_enumeration_value
    @enumeration_value = EnumerationValue.find(params[:id])
  end


  def enumeration_values_response
    if @params[:enumeration_name]
      enumeration = Enumeration.find_by_name(@params[:enumeration_name])
    elsif @params[:enumeration_id]
      enumeration = Enumeration.find_by_id(@params[:enumeration_id])
    else
      enumeration = nil
    end

    if enumeration
      enumerations = [enumeration]
    else
      enumerations = Enumeration.all
    end

    all_values = {}

    enumerations.each do |e|
      values = e.enumeration_values.order(:order)
      all_values[e.name] = values.map { |ev|
        { id: ev.id, value: ev.value, value_short: ev.value_short, associated_records_count: ev.associated_records_count }
      }
    end

    { enumeration_values: all_values }
  end

end
