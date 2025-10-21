class AddStatusToRoleApplications < ActiveRecord::Migration[8.0]
  def change
    add_column :role_applications, :status, :integer, default: 0

    # Update existing records to have default status
    reversible do |dir|
      dir.up do
        RoleApplication.update_all(status: 0)
      end
    end

    change_column_null :role_applications, :status, false
  end
end
