module ResumeHelpers
  extend ActiveSupport::Concern

  private

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

  def build_resume_with_file
    resume = @user.build_resume(resume_params)
    resume.file.attach(params[:resume][:file]) if params[:resume]&.dig(:file)&.present?
    resume
  end

  def handle_resume_create
    if @resume.save
      redirect_path = determine_redirect_path(params[:return_to], @user)
      redirect_to redirect_path, notice: 'Resume was successfully created.'
    else
      @return_to = params[:return_to]
      render :new, status: :unprocessable_entity
    end
  end

  def handle_update_result(result)
    @return_to = params[:return_to]
    if result[:success]
      handle_successful_update(result)
    else
      render :edit, status: result[:status]
    end
  end

  def handle_successful_update(result)
    if params[:stay_on_page]
      flash.now[:notice] = result[:notice]
      render :edit
    else
      redirect_path = determine_redirect_path(@return_to, result[:redirect_to])
      redirect_to redirect_path, notice: result[:notice]
    end
  end
end
