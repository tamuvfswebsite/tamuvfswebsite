class AddOrganizationalRoleIdToUsers < ActiveRecord::Migration[8.0]
  def change
    add_reference :users, :organizational_role, foreign_key: true, index: true
  end
end
