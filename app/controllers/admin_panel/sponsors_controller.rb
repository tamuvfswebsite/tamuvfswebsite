module AdminPanel
  class SponsorsController < ApplicationController
    before_action :set_sponsor, only: %i[show edit update destroy assign_users update_users]

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

    def assign_users
      @available_users = User.where(role: 'sponsor')
      @assigned_users = @sponsor.users
    end

    def update_users
      begin
        user_ids = params.dig(:sponsor, :user_ids)&.reject(&:blank?) || []
        
        @sponsor.users.clear
        
        if user_ids.any?
          users = User.where(id: user_ids, role: 'sponsor')
          @sponsor.users << users
        end
        
        redirect_to admin_panel_sponsor_path(@sponsor), notice: "Users updated successfully. #{@sponsor.users.count} user(s) assigned."
      rescue => e
        redirect_to assign_users_admin_panel_sponsor_path(@sponsor), alert: "Error updating users: #{e.message}"
      end
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
