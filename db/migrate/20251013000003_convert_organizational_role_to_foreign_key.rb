class ConvertOrganizationalRoleToForeignKey < ActiveRecord::Migration[7.2]
  def up
    # Add the foreign key column
    add_reference :users, :organizational_role, foreign_key: true

    # Migrate existing data
    User.reset_column_information
    User.find_each do |user|
      if user.organizational_role.present?
        role = OrganizationalRole.find_by(name: user.organizational_role)
        user.update_column(:organizational_role_id, role.id) if role
      end
    end

    # Remove the old string column
    remove_column :users, :organizational_role
  end

  def down
    # Add the string column back
    add_column :users, :organizational_role, :string

    # Migrate data back
    User.reset_column_information
    User.find_each do |user|
      if user.organizational_role_id.present?
        role = OrganizationalRole.find_by(id: user.organizational_role_id)
        user.update_column(:organizational_role, role.name) if role
      end
    end

    # Remove the foreign key column
    remove_reference :users, :organizational_role
  end
end
