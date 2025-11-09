# app/controllers/admin_panel/design_updates_controller.rb
module AdminPanel
  class DesignUpdatesController < ApplicationController
    before_action :set_design_update, only: %i[show edit update destroy]

    def index
      @design_updates = DesignUpdate.recent
    end

    def show; end

    def new
      @design_update = DesignUpdate.new
    end

    def edit; end

    def create
      @design_update = DesignUpdate.new(design_update_params)
      if @design_update.save
        redirect_to admin_panel_design_updates_path,
                    notice: 'Design update was successfully created.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @design_update.update(design_update_params)
        redirect_to admin_panel_design_updates_path,
                    notice: 'Design update was successfully updated.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @design_update.destroy
      redirect_to admin_panel_design_updates_path,
                  notice: 'Design update was successfully deleted.'
    end

    private

    def set_design_update
      @design_update = DesignUpdate.find(params[:id])
    end

    def design_update_params
      params.require(:design_update).permit(
        :title,
        :update_date,
        :pdf_file
      )
    end
  end
end
