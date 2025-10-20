class ResumesController < ApplicationController
  include ResumeAuthorization
  include ResumeValidations
  include ResumeFiltering

  # Handle authentication within authorization methods for index/show to prevent auto-redirect
  before_action :authorize_admin_or_sponsor, only: %i[index]

  # Require explicit authentication for create/update/delete actions
  before_action :authenticate_admin!, only: %i[new create edit update destroy]

  before_action :set_user
  before_action :set_resume, only: %i[show edit update destroy]
  before_action :authorize_own_resume, only: %i[show]

  def index
    @resumes = fetch_filtered_resumes
    load_filter_options
  end

  def show; end

  def new
    @return_to = params[:return_to]

    if @user.resume.present?
      redirect_to @user, alert: 'You already have a resume.'
    else
      @resume = @user.build_resume
    end
  end

  def edit
    @user ||= @resume.user
    @return_to = params[:return_to]

    return if @resume.user == @user

    redirect_to resumes_path, alert: 'You can only edit your own resume.'
  end

  def create
    return unless validate_user_for_create

    @resume = @user.build_resume(resume_params)
    @resume.file.attach(params[:resume][:file]) if params[:resume]&.dig(:file)&.present?

    if @resume.save
      redirect_path = determine_redirect_path(params[:return_to], @user)
      redirect_to redirect_path, notice: 'Resume was successfully created.'
    else
      @return_to = params[:return_to]
      render :new, status: :unprocessable_entity
    end
  end

  def update
    return unless validate_user_and_resume_for_update

    result = Resumes::Updater.new(@resume, @user, params).call

    @return_to = params[:return_to]
    if result[:success]
      if params[:stay_on_page]
        flash.now[:notice] = result[:notice]
        render :edit
      else
        redirect_path = determine_redirect_path(@return_to, result[:redirect_to])
        redirect_to redirect_path, notice: result[:notice]
      end
    else
      render :edit, status: result[:status]
    end
  end

  def destroy
    if @resume.user != @user
      redirect_to user_path(@user), alert: 'You can only delete your own resume.'
      return
    end

    @resume.destroy
    redirect_to user_path(@user), notice: 'Resume was successfully deleted.'
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
    params.require(:resume).permit(:file, :gpa, :graduation_date, :major, :organizational_role)
  end

  def determine_redirect_path(return_to_param, default_path)
    if return_to_param == 'application'
      new_role_application_path
    elsif return_to_param&.start_with?('application_edit_')
      application_id = return_to_param.split('_').last
      edit_role_application_path(application_id)
    else
      default_path
    end
  end
end
