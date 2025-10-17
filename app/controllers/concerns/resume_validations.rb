# frozen_string_literal: true

module ResumeValidations
  extend ActiveSupport::Concern

  private

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
end
