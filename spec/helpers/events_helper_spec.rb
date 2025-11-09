require 'rails_helper'

RSpec.describe EventsHelper, type: :helper do
  describe '#event_target_roles_display' do
    let(:event) { Event.new }

    context 'when event is public' do
      before { allow(event).to receive(:is_public?).and_return(true) }

      it 'returns "Public (Everyone)"' do
        expect(helper.event_target_roles_display(event)).to eq('Public (Everyone)')
      end
    end

    context 'when event has organizational roles' do
      let(:role1) { OrganizationalRole.new(name: 'AI') }
      let(:role2) { OrganizationalRole.new(name: 'Design') }

      before do
        allow(event).to receive(:is_public?).and_return(false)
        allow(event).to receive(:organizational_roles).and_return([role1, role2])
        allow(event.organizational_roles).to receive(:any?).and_return(true)
        allow(event.organizational_roles).to receive(:pluck).with(:name).and_return(['AI', 'Design'])
      end

      it 'returns comma-separated role names' do
        expect(helper.event_target_roles_display(event)).to eq('AI, Design')
      end
    end

    context 'when event has no roles and is not public' do
      before do
        allow(event).to receive(:is_public?).and_return(false)
        allow(event).to receive(:organizational_roles).and_return([])
        allow(event.organizational_roles).to receive(:any?).and_return(false)
      end

      it 'returns "All Roles"' do
        expect(helper.event_target_roles_display(event)).to eq('All Roles')
      end
    end
  end

  describe '#event_relevant_to_user?' do
    let(:event) { Event.new }
    let(:user_roles) { [] }

    context 'when event is public' do
      before { allow(event).to receive(:is_public?).and_return(true) }

      it 'returns true regardless of user roles' do
        expect(helper.event_relevant_to_user?(event, [])).to be true
        expect(helper.event_relevant_to_user?(event, [double('role')])).to be true
      end
    end

    context 'when event has no roles and is not public' do
      let(:role) { OrganizationalRole.new }

      before do
        allow(event).to receive(:is_public?).and_return(false)
        allow(event).to receive(:organizational_roles).and_return([])
        allow(event.organizational_roles).to receive(:empty?).and_return(true)
      end

      it 'returns true if user has roles' do
        expect(helper.event_relevant_to_user?(event, [role])).to be true
      end

      it 'returns false if user has no roles' do
        expect(helper.event_relevant_to_user?(event, [])).to be false
      end
    end

    context 'when event has specific roles' do
      let(:ai_role) { OrganizationalRole.new(name: 'AI') }
      let(:design_role) { OrganizationalRole.new(name: 'Design') }
      let(:service_role) { OrganizationalRole.new(name: 'Service') }

      before do
        allow(event).to receive(:is_public?).and_return(false)
        allow(event).to receive(:organizational_roles).and_return([ai_role, design_role])
        allow(event.organizational_roles).to receive(:empty?).and_return(false)
      end

      it 'returns true if user has matching role' do
        expect(helper.event_relevant_to_user?(event, [ai_role])).to be true
        expect(helper.event_relevant_to_user?(event, [design_role])).to be true
      end

      it 'returns false if user has no matching roles' do
        expect(helper.event_relevant_to_user?(event, [service_role])).to be false
        expect(helper.event_relevant_to_user?(event, [])).to be false
      end
    end
  end

  describe '#event_tag_badge' do
    let(:event) { Event.new }

    context 'when event is public' do
      before { allow(event).to receive(:is_public?).and_return(true) }

      it 'returns a public badge' do
        result = helper.event_tag_badge(event)
        expect(result).to include('Public')
        expect(result).to include('badge-public')
      end
    end

    context 'when event has organizational roles' do
      let(:role1) { OrganizationalRole.new(name: 'AI') }
      let(:role2) { OrganizationalRole.new(name: 'Design') }

      before do
        allow(event).to receive(:is_public?).and_return(false)
        allow(event).to receive(:organizational_roles).and_return([role1, role2])
        allow(event.organizational_roles).to receive(:any?).and_return(true)
        allow(event.organizational_roles).to receive(:map).and_yield(role1).and_yield(role2)
        allow(helper).to receive(:content_tag).with(:span, 'AI', class: 'badge badge-role').and_return('<span>AI</span>')
        allow(helper).to receive(:content_tag).with(:span, 'Design', class: 'badge badge-role').and_return('<span>Design</span>')
      end

      it 'returns badges for each role' do
        result = helper.event_tag_badge(event)
        expect(result).to be_a(String)
      end
    end

    context 'when event has no roles and is not public' do
      before do
        allow(event).to receive(:is_public?).and_return(false)
        allow(event).to receive(:organizational_roles).and_return([])
        allow(event.organizational_roles).to receive(:any?).and_return(false)
        allow(helper).to receive(:content_tag).with(:span, 'All Roles', class: 'badge badge-all').and_return('<span>All Roles</span>')
      end

      it 'returns an "All Roles" badge' do
        result = helper.event_tag_badge(event)
        expect(result).to include('All Roles')
      end
    end
  end
end

