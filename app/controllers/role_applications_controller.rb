class RoleApplicationsController < ApplicationController
  include RoleApplicationAuthorization

  before_action :authenticate_user_for_application, only: %i[new create edit update destroy]
  before_action :prevent_sponsor_access, only: %i[new create edit update destroy]
  before_action :set_role_application, only: %i[show edit update destroy]
  before_action :authorize_role_application_access, only: %i[show edit update destroy]
  before_action :check_resume_present, only: %i[new create]
  before_action :check_application_limit, only: %i[new create]
  before_action :load_organizational_roles, only: %i[new edit]

  # GET /role_applications or /role_applications.json
  def index
    if current_user
      # Show user's own applications
      @role_applications = current_user.role_applications.includes(:organizational_role).order(created_at: :desc)
    else
      redirect_to root_path, alert: 'Please sign in to view your applications.'
    end
  end

  # GET /role_applications/1 or /role_applications/1.json
  def show; end

  # GET /role_applications/new
  def new
    @role_application = RoleApplication.new
  end

  # GET /role_applications/1/edit
  def edit; end

  # POST /role_applications or /role_applications.json
  def create
    @role_application = current_user.role_applications.build(role_application_params)

    respond_to do |format|
      if @role_application.save
        format.html do
          redirect_to @role_application,
                      notice: 'Your application has been successfully submitted! ' \
                              'We will review it and get back to you soon.'
        end
        format.json { render :show, status: :created, location: @role_application }
      else
        load_organizational_roles
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @role_application.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /role_applications/1 or /role_applications/1.json
  def update
    respond_to do |format|
      if @role_application.update(role_application_params)
        format.html do
          redirect_to @role_application,
                      notice: 'Your application has been successfully updated.'
        end
        format.json { render :show, status: :ok, location: @role_application }
      else
        load_organizational_roles
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @role_application.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /role_applications/1 or /role_applications/1.json
  def destroy
    @role_application.destroy!

    respond_to do |format|
      format.html { redirect_to role_applications_path, notice: 'Application was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  private

  # Load organizational roles for the form
  def load_organizational_roles
    @organizational_roles = OrganizationalRole.all
  end

  def current_user
    @current_user ||= if admin_signed_in?
                        User.find_by(google_uid: current_admin.uid)
                      elsif session[:user_id]
                        User.find_by(id: session[:user_id])
                      end
  end
  helper_method :current_user

  # Use callbacks to share common setup or constraints between actions.
  def set_role_application
    @role_application = RoleApplication.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def role_application_params
    params.require(:role_application).permit(:org_role_id, :answer_1, :answer_2, :answer_3)
  end
end
