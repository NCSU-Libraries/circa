class UsersController < ApplicationController

  include UsersControllerCustom
  include SolrUtilities
  include NCSULdapUtils

  before_action :set_paper_trail_whodunnit

  # See Devise users controllers for new, create, edit, update, destroy

  def index
    @params = params
    @list = get_list_via_solr('user')
    @api_response = {
      users: @list,
      meta: { pagination: pagination_params }
    }

    render json: @api_response
  end


  def show
    if params[:id]
      where_params = { id: params[:id] }
    elsif params[:email]
      where_params = { email: params[:email] }
    else
      raise CircaExceptions::BadRequest
    end

    @user = User.where(where_params).first

    if !@user
      raise ActiveRecord::RecordNotFound
    else
      render json: @user
    end
  end


  # TODO - creation of staff users needs to be made generic - it is currently tied to Unity system and campus LDAP
  def create
    params[:user][:user_role_id] ||= UserRole.lowest.id

    if !current_user.can_assign_role?(params[:user][:user_role_id])
      role = UserRole.find(params[:user][:user_role_id])
      render json: { error: { detail: "Forbidden: This operation is only available to users with role '#{ role.name }'.", status: 403 } }, status: 403
      return
    else
      @user = User.find_by_email(params[:user][:email])
      if @user
        raise CircaExceptions::BadRequest, "User with email #{params[:user][:email]} already exists."
      else
        params[:user][:password] ||= SecureRandom.hex(8)
        if params[:user][:agreement_confirmed]
          params[:user][:agreement_confirmed_at] = Time.now
        end
        @user = User.create!(user_params)
        update_notes
        render json: @user
        return
      end
    end

  end


  def update
    @user = User.find params[:id]

    if !current_user.can_assign_role?(params[:user][:user_role_id])
      role = UserRole.find(params[:user][:user_role_id])
      render json: { error: { detail: "Forbidden: This operation is only available to users with role '#{ role.name }'.", status: 403 } }, status: 403
      return
    else
      if params[:user][:agreement_confirmed] && !@user.agreement_confirmed_at
        params[:user][:agreement_confirmed_at] = Time.now
      elsif !params[:user][:agreement_confirmed] && @user.agreement_confirmed_at
        @user.update_columns(agreement_confirmed_at: nil)
      end
      @user.update!(user_params)
      update_notes
      render json: @user
      return
    end
  end


  def send_password_reset_link
    @user = User.find params[:id]
    if !@user.send_reset_password_instructions
      raise CircaExceptions::BadRequest
    else
      render json: { password_reset_instructions: true }
    end
  end


  private


  def user_params
    params.require(:user).permit(:email, :unity_id, :password, :patron_type_id, :position, :affiliation, :first_name, :last_name, :display_name,
      :address1, :address2, :city, :state, :zip, :country, :phone, :agreement_confirmed_at, :user_role_id)
  end


  def update_notes
    @notes = params[:user][:notes] || []
    if (@user.notes.length == 0) && (@notes.length == 0)
      return
    elsif (@user.notes.length == 0) && (@notes.length > 0)
      @notes.each { |n| @user.notes.create!(content: n['content']) }
    elsif (@notes.length == 0) && (@user.notes.length > 0)
      @user.notes.each { |n| n.destroy! }
    else
      notes_length = @user.notes.length > @notes.length ? @user.notes.length : @notes.length
      (0..(notes_length - 1)).to_a.each do |i|
        if @user.notes[i] && @notes[i]
          @user.notes[i].update_attributes(content: @notes[i]['content'])
        elsif !@user.notes[i] && @notes[i]
          @user.notes.create!(content: @notes[i]['content'])
        elsif @user.notes[i] && !@notes[i]
          @user.notes[i].destroy!
        end
      end
    end
  end


end
