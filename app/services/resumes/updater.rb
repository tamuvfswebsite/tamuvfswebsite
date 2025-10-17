module Resumes
  class Updater
    def initialize(resume, user, params)
      @resume = resume
      @user = user
      @params = params
    end

    def call
      return validation_error if file_required_but_missing?

      attach_file_if_present

      if file_only_update?
        process_file_only_update
      else
        process_metadata_update
      end
    end

    private

    attr_reader :resume, :user, :params

    def file_required_but_missing?
      !resume.file.attached? && params.dig(:resume, :file).nil?
    end

    def validation_error
      resume.errors.add(:file, "can't be blank")
      { success: false, status: :unprocessable_entity }
    end

    def attach_file_if_present
      return unless params[:resume]&.dig(:file)&.present?

      resume.file.attach(params[:resume][:file])
    end

    def file_only_update?
      params[:file_only].present?
    end

    def process_file_only_update
      if resume.save
        { success: true, redirect_to: user, notice: 'Resume file was successfully updated.' }
      else
        { success: false, status: :unprocessable_entity }
      end
    end

    def process_metadata_update
      permitted_params = params.require(:resume).permit(:file, :gpa, :graduation_date, :major, :organizational_role)

      if resume.update(permitted_params.except(:file))
        { success: true, redirect_to: user, notice: 'Resume was successfully updated.' }
      else
        { success: false, status: :unprocessable_entity }
      end
    end
  end
end
