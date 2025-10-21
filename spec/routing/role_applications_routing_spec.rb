require 'rails_helper'

RSpec.describe RoleApplicationsController, type: :routing do
  describe 'routing' do
    it 'routes to #new' do
      expect(get: '/role_applications/new').to route_to('role_applications#new')
    end

    it 'routes to #show' do
      expect(get: '/role_applications/1').to route_to('role_applications#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/role_applications/1/edit').to route_to('role_applications#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/role_applications').to route_to('role_applications#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/role_applications/1').to route_to('role_applications#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/role_applications/1').to route_to('role_applications#update', id: '1')
    end
  end
end
