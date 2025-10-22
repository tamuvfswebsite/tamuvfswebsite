module AdminPanel
  class OrganizationalRolesController < BaseController
    before_action :set_organizational_role, only: %i[show edit update destroy]

    # GET /admin_panel/organizational_roles
    def index
      @organizational_roles = OrganizationalRole.all
    end

    # GET /admin_panel/organizational_roles/1
    def show; end

    # GET /admin_panel/organizational_roles/new
    def new
      @organizational_role = OrganizationalRole.new
    end

    # GET /admin_panel/organizational_roles/1/edit
    def edit; end

    # POST /admin_panel/organizational_roles
    def create
      @organizational_role = OrganizationalRole.new(organizational_role_params)

      respond_to do |format|
        if @organizational_role.save
          handle_successful_create(format)
        else
          handle_failed_create(format)
        end
      end
    end

    # PATCH/PUT /admin_panel/organizational_roles/1
    def update
      respond_to do |format|
        if @organizational_role.update(organizational_role_params)
          format.html do
            redirect_to admin_panel_organizational_role_path(@organizational_role),
                        notice: 'Organizational role was successfully updated.'
          end
          format.json do
            render :show, status: :ok, location: admin_panel_organizational_role_path(@organizational_role)
          end
        else
          format.html { render :edit, status: :unprocessable_content }
          format.json { render json: @organizational_role.errors, status: :unprocessable_content }
        end
      end
    end

    # DELETE /admin_panel/organizational_roles/1
    def destroy
      @organizational_role.destroy!

      respond_to do |format|
        format.html do
          redirect_to admin_panel_organizational_roles_path, notice: 'Organizational role was successfully destroyed.',
                                                             status: :see_other
        end
        format.json { head :no_content }
      end
    end

    private

    def set_organizational_role
      @organizational_role = OrganizationalRole.find(params[:id])
    end

    def organizational_role_params
      params.require(:organizational_role).permit(:name, :description)
    end

    def handle_successful_create(format)
      format.html do
        redirect_to admin_panel_organizational_role_path(@organizational_role),
                    notice: 'Organizational role was successfully created.'
      end
      format.json { render :show, status: :created, location: @organizational_role }
    end

    def handle_failed_create(format)
      format.html { render_new_or_error }
      format.json { render json: @organizational_role.errors, status: :unprocessable_content }
    end

    def render_new_or_error
      if lookup_context.exists?('new', controller_path)
        render :new, status: :unprocessable_content
      else
        render plain: @organizational_role.errors.full_messages.join(', '), status: :unprocessable_content
      end
    end
  end
end
