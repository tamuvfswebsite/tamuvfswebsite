class UsersController < ApplicationController
  before_action :set_user, only: %i[ show edit update destroy ]
  before_action :ensure_admin_user, except: [:show]
  before_action :ensure_own_profile_or_admin, only: [:show]

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
    if @user.google_uid == current_admin.uid && user_params[:role].present?
      respond_to do |format|
        format.html { redirect_to @user, alert: 'You cannot change your own role.', status: :see_other }
        format.json { render json: { error: 'You cannot change your own role.' }, status: :forbidden }
      end
      return
    end

    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.', status: :see_other }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
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
    params.expect(user: [:role, { organizational_role_ids: [] }])
  end

  def ensure_own_profile_or_admin
    return if admin_user? # Admins can view anyone's profile

    # Non-admins can only view their own profile
    return if admin_signed_in? && @user.google_uid == current_admin.uid

    flash[:alert] = 'Access denied. You can only view your own profile.'
    redirect_to homepage_path
  end
end
