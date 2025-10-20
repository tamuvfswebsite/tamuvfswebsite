module AdminPanel
  class SponsorsController < ApplicationController
    before_action :set_sponsor, only: %i[show edit update destroy]

    def index
      @sponsors = Sponsor.all
    end

    def show; end

    def new
      @sponsor = Sponsor.new
    end

    def edit; end

    def create
      @sponsor = Sponsor.new(sponsor_params)
      if @sponsor.save
        redirect_to admin_panel_sponsor_path(@sponsor), notice: 'Sponsor was successfully created.'
      else
        render :new
      end
    end

    def update
      if @sponsor.update(sponsor_params)
        redirect_to admin_panel_sponsor_path(@sponsor), notice: 'Sponsor was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @sponsor.destroy
      redirect_to admin_panel_sponsors_path, notice: 'Sponsor was successfully deleted.'
    end

    private

    def set_sponsor
      @sponsor = Sponsor.find(params[:id])
    end

    def sponsor_params
      params.require(:sponsor).permit(:company_name, :website, :logo_url, :resume_access)
    end
  end
end
