module Resumes
  class Updater
    attr_reader :resume, :user, :params

    def initialize(resume, user, params)
      @resume = resume
      @user = user
      @params = params
    end

    def call
      return file_missing_error if file_required_but_missing?

      attach_file_if_present

      if file_only_update?
        update_file_only
      else
        update_metadata
      end
    end

    private

    def file_required_but_missing?
      !resume.file.attached? && params.dig(:resume, :file).nil?
    end

    def file_missing_error
      resume.errors.add(:file, "can't be blank")
      { success: false, status: :unprocessable_content }
    end

    def attach_file_if_present
      return unless params[:resume]&.dig(:file)&.present?

      resume.file.attach(params[:resume][:file])
    end

    def file_only_update?
      params[:file_only].present?
    end

    def update_file_only
      if resume.save
        success_response('Resume file was successfully updated.')
      else
        error_response
      end
    end

    def update_metadata
      if resume.update(permitted_params)
        success_response('Resume was successfully updated.')
      else
        error_response
      end
    end

    def permitted_params
      params.require(:resume).permit(:gpa, :graduation_date, :major)
    end

    def success_response(message)
      { success: true, redirect_to: user, notice: message }
    end

    def error_response
      { success: false, status: :unprocessable_content }
    end
  end
end
