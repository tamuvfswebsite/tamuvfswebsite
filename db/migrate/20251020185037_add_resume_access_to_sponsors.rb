class AddResumeAccessToSponsors < ActiveRecord::Migration[8.0]
  def change
    add_column :sponsors, :resume_access, :boolean
  end
end
