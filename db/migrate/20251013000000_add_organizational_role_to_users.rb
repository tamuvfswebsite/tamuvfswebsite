class AddOrganizationalRoleToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :organizational_role, :string
  end
end
