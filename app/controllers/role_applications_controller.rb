class RoleApplicationsController < ApplicationController
  before_action :set_role_application, only: %i[ show edit update destroy ]

  # GET /role_applications or /role_applications.json
  def index
    @role_applications = RoleApplication.all
  end

  # GET /role_applications/1 or /role_applications/1.json
  def show
  end

  # GET /role_applications/new
  def new
    @role_application = RoleApplication.new
  end

  # GET /role_applications/1/edit
  def edit
  end

  # POST /role_applications or /role_applications.json
  def create
    @role_application = RoleApplication.new(role_application_params)

    respond_to do |format|
      if @role_application.save
        format.html { redirect_to @role_application, notice: "Role application was successfully created." }
        format.json { render :show, status: :created, location: @role_application }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @role_application.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /role_applications/1 or /role_applications/1.json
  def update
    respond_to do |format|
      if @role_application.update(role_application_params)
        format.html { redirect_to @role_application, notice: "Role application was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @role_application }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @role_application.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /role_applications/1 or /role_applications/1.json
  def destroy
    @role_application.destroy!

    respond_to do |format|
      format.html { redirect_to role_applications_path, notice: "Role application was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_role_application
      @role_application = RoleApplication.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def role_application_params
      params.expect(role_application: [ :user_id, :org_role, :essay ])
    end
end
