class ChangeOrgRoleToOrgRoleIdInRoleApplications < ActiveRecord::Migration[8.0]
  def change
    # Rename the column from org_role (string) to org_role_id (integer)
    remove_column :role_applications, :org_role, :string
    add_reference :role_applications, :org_role, foreign_key: { to_table: :organizational_roles }, null: false
  end
end
