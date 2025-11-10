require 'rails_helper'

RSpec.describe 'sponsors/edit.html.erb', type: :view do
  let(:sponsor) do
    Sponsor.create!(
      company_name: 'Test Company',
      contact_email: 'contact@test.com',
      phone_number: '(555) 123-4567',
      company_description: 'A test company',
      website: 'https://www.test.com'
    )
  end

  before do
    assign(:sponsor, sponsor)
    render
  end

  it 'displays the page heading' do
    expect(rendered).to have_selector('h1', text: 'Edit Your Company Profile')
  end

  it 'renders the form partial' do
    expect(rendered).to have_selector('form')
  end

  it 'has a company name field' do
    expect(rendered).to have_field('Sponsor Company Name', with: 'Test Company')
  end

  it 'has a contact email field' do
    expect(rendered).to have_field('Contact Email', with: 'contact@test.com')
  end

  it 'has a phone number field' do
    expect(rendered).to have_field('Phone Number', with: '(555) 123-4567')
  end

  it 'has a company description field' do
    expect(rendered).to have_field('Company Description', with: 'A test company')
  end

  it 'has a website field' do
    expect(rendered).to have_field('Sponsor Website', with: 'https://www.test.com')
  end

  it 'has a save button' do
    expect(rendered).to have_button('Save Changes')
  end

  it 'has a cancel link' do
    expect(rendered).to have_link('Cancel', href: sponsor_dashboard_index_path)
  end

  it 'has a back to dashboard link' do
    expect(rendered).to have_link('Back to Dashboard', href: sponsor_dashboard_index_path)
  end
end
