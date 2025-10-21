class CreateSponsors < ActiveRecord::Migration[8.0]
  def change
    create_table :sponsors do |t|
      t.string :company_name
      t.string :logo_url
      t.string :website

      t.timestamps
    end
  end
end
