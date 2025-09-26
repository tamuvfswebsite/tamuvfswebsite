class Admin::BaseController < ApplicationController
  before_action :authenticate_admin!

  private

  def authenticate_admin!
    redirect_to new_admin_session_path unless admin_signed_in?
  end
end