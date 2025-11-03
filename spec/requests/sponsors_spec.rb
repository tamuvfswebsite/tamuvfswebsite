require 'rails_helper'

RSpec.describe "Sponsors", type: :request do
  describe "GET /show" do
    it "returns http success" do
      get "/sponsors/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      get "/sponsors/edit"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/sponsors/update"
      expect(response).to have_http_status(:success)
    end
  end

end
