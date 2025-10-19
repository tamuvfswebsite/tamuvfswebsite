class ResumesController < ApplicationController
  include ResumeAuthorization
  include ResumeValidations

  # Handle authentication within authorization methods for index/show to prevent auto-redirect
  before_action :authorize_admin_or_sponsor, only: %i[index]
  before_action :authorize_own_resume, only: %i[show]

  # Require explicit authentication for create/update/delete actions
  before_action :authenticate_admin!, only: %i[new create edit update destroy]

  before_action :set_user
  before_action :set_resume, only: %i[show edit update destroy]

  def index
    per = (params[:per] || 20).to_i
    per = 100 if per > 100

    @resumes = Resumes::IndexQuery.call(sort: params[:sort], direction: params[:direction])
                                  .page(params[:page]).per(per)
  end

  def show; end

  def new
    if @user.resume.present?
      redirect_to @user, alert: 'You already have a resume.'
    else
      @resume = @user.build_resume
    end
  end

  def edit
    # Load the resume's user if we don't have it
    @user ||= @resume.user
    return if @resume.user == @user

    redirect_to resumes_path, alert: 'You can only edit your own resume.'
    nil
  end

  def create
    return unless validate_user_for_create

    @resume = @user.build_resume(resume_params)
    @resume.file.attach(params[:resume][:file]) if params[:resume]&.dig(:file)&.present?

    if @resume.save
      redirect_to @user, notice: 'Resume was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    return unless validate_user_and_resume_for_update

    result = Resumes::Updater.new(@resume, @user, params).call

    if result[:success]
      redirect_to result[:redirect_to], notice: result[:notice]
    else
      render :edit, status: result[:status]
    end
  end

  def destroy
    # @resume is set by set_resume before_action, @user by set_user before_action
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
                # For routes like /resumes/:id
                resume = Resume.find_by(id: params[:id])
                # Set @user from the resume if we don't have it from params
                @user ||= resume&.user
                resume
              elsif @user
                # For nested routes like /users/:user_id/resume
                @user.resume
              end

    return if @resume

    redirect_to (@user ? user_path(@user) : resumes_path), alert: 'Resume not found.'
  end

  def resume_params
    params.require(:resume).permit(:file, :gpa, :graduation_date, :major, :organizational_role)
  end
end
