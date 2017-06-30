class UserRolesController < ApplicationController

  before_action :set_user_role, only: [ :show, :update, :destroy ]


  def index
    render json: user_roles_response
  end


  def show
    render json: @user_role
  end


  def create
    @user_role = UserRole.create!(user_role_params)
    render json: @user_role
  end


  def update
    @user_role.update_attributes(user_role_params)
    render json: @user_role
  end


  def merge
    @merge_from_id = params[:merge_from_id]
    @merge_into_id = params[:merge_into_id]
    UserRole.merge(@merge_from_id, @merge_into_id)
    render json: user_roles_response
  end


  def destroy
    @params = params
    if !@user_role.deletable?
      raise CircaExceptions::ReferentialIntegrityConflict, "The user role cannot be deleted due to a referential integrity conflict"
    else
      @user_role.destroy
      render json: {}
    end
  end


  def update_levels
    @params = params
    if !params[:user_roles]
      raise CircaExceptions::BadRequest, "Levels were not set due to an error."
    else
      user_roles = params[:user_roles]
      user_roles.delete_if { |ur| ['superadmin', 'admin'].include?(ur['name']) }
      user_roles.each_index do |i|
        id = user_roles[i]['id']
        user_role = UserRole.find(id)
        new_level = (i + 1) * 10
        user_role.update_attributes(level: new_level)
      end
    end
    render json: user_roles_response
  end


  private


  def user_role_params
    p = params.require(:user_role).permit(:name, :level)
    p[:name] = format_name(p[:name])
    p
  end


  def set_user_role
    @user_role = UserRole.find(params[:id])
  end


  def user_roles_response
    UserRole.where('level > 0').order(:level).all
  end

  def format_name(name)
    name.downcase.gsub(/[^A-Za-z0-1_]/, '_').gsub(/_{2,}/,'_').gsub(/_$/,'')
  end

end
