class UsersController < ApplicationController
  include UsersHelper

  before_action :set_user, only: %i[ show edit update destroy ]
  before_action :ensure_admin_user, except: [:show]
  before_action :ensure_own_profile_or_admin, only: [:show]
  helper_method :editing_own_profile?

  # GET /users or /users.json
  def index
    @users = User.all

    # Filter by organizational role if provided
    if params[:organizational_role_id].present?
      @users = @users.joins(:organizational_roles)
                     .where(organizational_roles: { id: params[:organizational_role_id] })
                     .distinct
    end

    @organizational_roles = OrganizationalRole.all.order(:name)
  end

  # GET /users/1 or /users/1.json
  def show; end

  # GET /users/1/edit
  def edit; end

  # PATCH/PUT /users/1 or /users/1.json
  def update
    return if prevent_self_role_change

    perform_update
  end

  # DELETE /users/1 or /users/1.json
  def destroy
    @user.destroy!

    respond_to do |format|
      format.html { redirect_to users_path, notice: 'User was successfully destroyed.', status: :see_other }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def user_params
    params.expect(user: [:role, :points, { organizational_role_ids: [] }])
  end

  def ensure_own_profile_or_admin
    return if admin_user? # Admins can view anyone's profile

    # Non-admins can only view their own profile
    return if own_account?(@user)

    flash[:alert] = 'Access denied. You can only view your own profile.'
    redirect_to root_path
  end

  def prevent_self_role_change
    return false unless attempting_self_role_change?

    respond_to do |format|
      format.html do
        flash[:alert] = 'You cannot change your own role.'
        redirect_to @user
      end
      format.json do
        render json: { error: 'You cannot change your own role.' }, status: :forbidden
      end
    end
    true
  end

  def attempting_self_role_change?
    editing_own_profile?(@user) && user_params[:role].present? && user_params[:role] != @user.role
  end

  def perform_update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.', status: :see_other }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @user.errors, status: :unprocessable_content }
      end
    end
  end
end
