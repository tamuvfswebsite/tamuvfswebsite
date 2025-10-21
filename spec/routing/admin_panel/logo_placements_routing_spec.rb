require "rails_helper"

RSpec.describe AdminPanel::LogoPlacementsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/admin_panel/logo_placements").to route_to("admin_panel/logo_placements#index")
    end

    it "routes to #new" do
      expect(get: "/admin_panel/logo_placements/new").to route_to("admin_panel/logo_placements#new")
    end

    it "routes to #show" do
      expect(get: "/admin_panel/logo_placements/1").to route_to("admin_panel/logo_placements#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/admin_panel/logo_placements/1/edit").to route_to("admin_panel/logo_placements#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/admin_panel/logo_placements").to route_to("admin_panel/logo_placements#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/admin_panel/logo_placements/1").to route_to("admin_panel/logo_placements#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/admin_panel/logo_placements/1").to route_to("admin_panel/logo_placements#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/admin_panel/logo_placements/1").to route_to("admin_panel/logo_placements#destroy", id: "1")
    end
  end
end
