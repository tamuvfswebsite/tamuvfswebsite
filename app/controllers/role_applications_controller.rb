class RoleApplicationsController < ApplicationController
  before_action :authenticate_user_for_application, only: %i[new create edit update]
  before_action :set_role_application, only: %i[show edit update]
  before_action :authorize_role_application_access, only: %i[show edit update]
  before_action :check_existing_application, only: %i[new create]
  before_action :check_resume_present, only: %i[new create]
  before_action :load_organizational_roles, only: %i[new edit]

  # GET /role_applications or /role_applications.json
  def index
    # This action is not used in public routes, only in admin_panel
    @role_applications = RoleApplication.all
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
    @role_application = current_user.build_role_application(role_application_params)

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

  private

  # Authenticate user via current_user helper (assumes OAuth flow sets this)
  def authenticate_user_for_application
    return if current_user

    # Store the location they're trying to access
    session[:applying_for_role] = true
    # Redirect to OAuth for authentication
    redirect_to admin_google_oauth2_omniauth_authorize_path, alert: 'Please sign in to apply.'
  end

  # Check if user already has an application (used in new/create)
  def check_existing_application
    return unless current_user.role_application.present?

    redirect_to root_path, alert: 'You have already submitted an application.'
  end

  # Check if user has a resume (used in new/create)
  def check_resume_present
    return if current_user.resume&.file&.attached?

    redirect_to new_user_resume_path(current_user, return_to: 'application'),
                alert: 'Please upload your resume before applying.'
  end

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

  def authorize_role_application_access
    unless current_user
      session[:applying_for_role] = true
      redirect_to admin_google_oauth2_omniauth_authorize_path, alert: 'Please sign in to view this application.'
      return
    end

    # Allow admins to view any application
    return if admin_signed_in? && current_user.role == 'admin'

    # Allow users to view only their own application
    return if @role_application&.user_id == current_user.id

    redirect_to root_path, alert: 'You can only view your own application.'
  end

  # Only allow a list of trusted parameters through.
  def role_application_params
    params.require(:role_application).permit(:org_role_id, :essay)
  end
end
