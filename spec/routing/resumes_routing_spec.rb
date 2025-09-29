require 'rails_helper'

RSpec.describe ResumesController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/resumes').to route_to('resumes#index')
    end

    it 'routes to #new' do
      expect(get: '/users/1/resume/new').to route_to('resumes#new', user_id: '1')
    end

    it 'routes to #show' do
      expect(get: '/users/1/resume').to route_to('resumes#show', user_id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/users/1/resume/edit').to route_to('resumes#edit', user_id: '1')
    end

    it 'routes to #create' do
      expect(post: '/users/1/resume').to route_to('resumes#create', user_id: '1')
    end

    it 'routes to #update via PUT' do
      expect(put: '/users/1/resume').to route_to('resumes#update', user_id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/users/1/resume').to route_to('resumes#update', user_id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/resumes/1').to route_to('resumes#destroy', id: '1')
    end
  end
end
