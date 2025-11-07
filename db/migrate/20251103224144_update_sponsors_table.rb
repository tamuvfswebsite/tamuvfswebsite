class UpdateSponsorsTable < ActiveRecord::Migration[7.0]
  def change
    remove_column :sponsors, :logo_url, :string

    add_column :sponsors, :tier, :string
    add_column :sponsors, :contact_email, :string
    add_column :sponsors, :phone_number, :string
    add_column :sponsors, :company_description, :text
  end
end
