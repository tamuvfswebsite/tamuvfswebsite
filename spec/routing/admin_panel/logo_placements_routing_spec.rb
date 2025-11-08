require 'rails_helper'

RSpec.describe AdminPanel::LogoPlacementsController, type: :routing do
  describe 'routing' do
    it 'routes to #new' do
      expect(get: '/admin_panel/sponsors/1/logo_placements/new').to route_to('admin_panel/logo_placements#new',
                                                                             sponsor_id: '1')
    end

    it 'routes to #show' do
      expect(get: '/admin_panel/sponsors/1/logo_placements/1').to route_to('admin_panel/logo_placements#show',
                                                                           sponsor_id: '1', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/admin_panel/sponsors/1/logo_placements/1/edit').to route_to('admin_panel/logo_placements#edit',
                                                                                sponsor_id: '1', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/admin_panel/sponsors/1/logo_placements').to route_to('admin_panel/logo_placements#create',
                                                                          sponsor_id: '1')
    end

    it 'routes to #update via PUT' do
      expect(put: '/admin_panel/sponsors/1/logo_placements/1').to route_to('admin_panel/logo_placements#update',
                                                                           sponsor_id: '1', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/admin_panel/sponsors/1/logo_placements/1').to route_to('admin_panel/logo_placements#update',
                                                                             sponsor_id: '1', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/admin_panel/sponsors/1/logo_placements/1').to route_to('admin_panel/logo_placements#destroy',
                                                                              sponsor_id: '1', id: '1')
    end

    it 'does not route to #index' do
      expect(get: '/admin_panel/sponsors/1/logo_placements').not_to be_routable
    end
  end
end
