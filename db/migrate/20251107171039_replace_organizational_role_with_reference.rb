class ReplaceOrganizationalRoleWithReference < ActiveRecord::Migration[8.0]
  def change
    # Remove the old string column from resumes
    remove_column :resumes, :organizational_role, :string

    # Add organizational_role_id to users table (this is the source of truth)
    add_reference :users, :organizational_role, foreign_key: true, index: true
  end
end
