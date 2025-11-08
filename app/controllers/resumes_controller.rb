class ResumesController < ApplicationController
  include ResumeAuthorization
  include ResumeValidations
  include ResumeFiltering
  include ResumeHelpers

  # Handle authentication within authorization methods for index/show to prevent auto-redirect
  before_action :authorize_admin_or_sponsor, only: %i[index]

  # Require explicit authentication for create/update/delete actions
  before_action :authenticate_admin!, only: %i[new create edit update destroy]

  # Prevent sponsors from creating/editing/deleting resumes
  before_action :prevent_sponsor_access, only: %i[new create edit update destroy]

  before_action :set_user
  before_action :set_resume, only: %i[show edit update destroy download]
  before_action :authorize_own_resume, only: %i[show]

  def index
    @resumes = fetch_filtered_resumes
    load_filter_options
  end

  def show; end

  def new
    @return_to = params[:return_to]

    # Admins can create resumes for anyone, users can only create their own
    unless current_authenticated_user&.role == 'admin' || @user.id == current_authenticated_user&.id
      redirect_to root_path, alert: 'You can only create your own resume.'
      return
    end

    if @user.resume.present?
      redirect_to @user, alert: 'User already has a resume.'
    else
      @resume = @user.build_resume
    end
  end

  def edit
    @user ||= @resume.user
    @return_to = params[:return_to]

    # Admins can edit any resume, users can only edit their own
    return if current_authenticated_user&.role == 'admin'
    return if @resume.user_id == current_authenticated_user&.id

    redirect_to resumes_path, alert: 'You can only edit your own resume.'
  end

  def create
    return unless validate_user_for_create

    @resume = build_resume_with_file
    handle_resume_create
  end

  def update
    return unless validate_user_and_resume_for_update

    result = Resumes::Updater.new(@resume, @user, params).call
    handle_update_result(result)
  end

  def destroy
    # Only allow users to delete their own resume
    if @resume.user_id != current_authenticated_user&.id
      redirect_to user_path(@user), alert: 'You can only delete your own resume.'
      return
    end

    @resume.destroy
    redirect_to user_path(@user), notice: 'Resume was successfully deleted.'
  end

  def download
    current_user = admin_signed_in? ? User.find_by(google_uid: current_admin.uid) : nil

    # Track download only if user is a sponsor
    if current_user&.role == 'sponsor'
      ResumeDownload.create!(
        user: current_user,
        resume: @resume,
        downloaded_at: Time.current
      )
    end

    # Send the file directly instead of redirecting
    redirect_to rails_blob_path(@resume.file, disposition: 'attachment'), allow_other_host: true
  end

  private

  def set_user
    @user = User.find(params[:user_id]) if params[:user_id]
  end

  def set_resume
    @resume = if params[:id]
                Resume.find_by(id: params[:id]).tap do |resume|
                  @user ||= resume&.user
                end
              elsif @user
                @user.resume
              end

    return if @resume

    redirect_to (@user ? user_path(@user) : resumes_path), alert: 'Resume not found.'
  end

  def resume_params
    params.require(:resume).permit(:file, :gpa, :graduation_date, :major)
  end

  def validate_user_for_create
    unless @user
      redirect_to root_path, alert: 'User not found'
      return false
    end

    # Admins can create resumes for anyone, users can only create their own
    unless current_authenticated_user&.role == 'admin' || @user.id == current_authenticated_user&.id
      redirect_to root_path, alert: 'You can only create your own resume.'
      return false
    end

    if @user.resume.present?
      redirect_to @user, alert: 'User already has a resume.'
      return false
    end

    true
  end

  def prevent_sponsor_access
    return unless current_authenticated_user&.sponsor?

    redirect_to root_path, alert: 'Sponsors cannot create, edit, or delete resumes.'
  end
end
