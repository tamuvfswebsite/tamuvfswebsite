module AdminPanel
  class LogoPlacementsController < BaseController
    before_action :set_sponsor
    before_action :set_logo_placement, only: %i[ show edit update destroy ]

    def show; end

    def new
      @logo_placement = @sponsor.logo_placements.new
    end

    def edit; end

    def create
      @logo_placement = @sponsor.logo_placements.new(logo_placement_params)

      if @logo_placement.save
        redirect_to admin_panel_sponsor_path(@sponsor),
                    notice: 'Logo placement was successfully created.',
                    status: :see_other
      else
        render :new, status: :unprocessable_content
      end
    end

    def update
      if @logo_placement.update(logo_placement_params)
        redirect_to admin_panel_sponsor_path(@sponsor),
                    notice: 'Logo placement was successfully updated.',
                    status: :see_other
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @logo_placement.destroy
      redirect_to admin_panel_sponsor_path(@sponsor),
                  notice: 'Logo placement was successfully destroyed.'
    end

    private

    def set_sponsor
      @sponsor = Sponsor.find(params[:sponsor_id])
    end

    def set_logo_placement
      @logo_placement = @sponsor.logo_placements.find(params[:id])
    end

    def logo_placement_params
      params.require(:logo_placement).permit(:page_name, :section, :displayed)
    end
  end
end
