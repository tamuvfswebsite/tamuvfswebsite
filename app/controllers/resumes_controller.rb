class ResumesController < ApplicationController
  before_action :set_user
  before_action :set_resume, only: [:show, :edit, :update, :destroy]

  def index
    @resumes = Resume.all
  end

  def show
  end

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
    unless @resume.user == @user
      redirect_to resumes_path, alert: 'You can only edit your own resume.'
      return
    end
  end

  def create
    if @user.resume.present?
      redirect_to @user, alert: 'You already have a resume.'
    else
      @resume = @user.build_resume(resume_params)
      if @resume.save
        redirect_to @user, notice: 'Resume was successfully created.'
      else
        render :new, status: :unprocessable_entity
      end
    end
  end

  def update
    # Load the resume's user if we don't have it
    @user ||= @resume.user
    if @resume.user == @user
      if @resume.update(resume_params)
        redirect_to resumes_path, notice: 'Resume was successfully updated.'
      else
        render :edit, status: :unprocessable_entity
      end
    else
      redirect_to resumes_path, alert: 'You can only update your own resume.'
    end
  end

  def destroy
    # Load the resume's user if we don't have it
    @user ||= @resume.user
    if @resume.user == @user
      @resume.destroy
      redirect_to resumes_path
    else
      redirect_to resumes_path, alert: 'You can only delete your own resume.'
    end
  end

  private

  def set_user
    @user = User.find(params[:user_id]) if params[:user_id]
  end

  def set_resume
    @resume = if params[:id]
                Resume.find_by(id: params[:id])
              else
                @user&.resume
              end
    
    redirect_to (@user || root_path), alert: 'Resume not found.' unless @resume
  end

  def resume_params
    params.require(:resume).permit(:file)
  end
end
