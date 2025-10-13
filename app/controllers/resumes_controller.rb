class ResumesController < ApplicationController
  before_action :set_user
  before_action :set_resume, only: %i[show edit update destroy]

  def index
    @resumes = Resume.all
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

    @resume = @user.build_resume
    attach_file_if_present

    if @resume.save
      redirect_to @user, notice: 'Resume was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    return unless validate_user_and_resume_for_update

    # Check if the user is trying to remove the file
    if params.dig(:resume, :file).nil?
      @resume.errors.add(:file, "can't be blank")
      render :edit, status: :unprocessable_entity
      return
    end

    attach_file_if_present

    if @resume.save
      redirect_to user_path(@user), notice: 'Resume was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
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

  def validate_user_for_create
    unless @user
      redirect_to root_path, alert: 'User not found'
      return false
    end

    if @user.resume.present?
      redirect_to @user, alert: 'You already have a resume.'
      return false
    end

    true
  end

  def validate_user_and_resume_for_update
    unless @user && @resume
      redirect_to root_path, alert: 'Resume not found'
      return false
    end

    if @resume.user != @user
      redirect_to user_path(@user), alert: 'You can only update your own resume.'
      return false
    end

    true
  end

  def attach_file_if_present
    return unless params[:resume]&.dig(:file)&.present?

    @resume.file.attach(params[:resume][:file])
  end

  def resume_params
    params.require(:resume).permit(:file)
  end
end
