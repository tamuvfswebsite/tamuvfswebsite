class CreateEventOrganizationalRoles < ActiveRecord::Migration[8.0]
  def change
    return if table_exists?(:event_organizational_roles)

    create_table :event_organizational_roles do |t|
      t.references :event, null: false, foreign_key: true
      t.references :organizational_role, null: false, foreign_key: true

      t.timestamps
    end

    add_index :event_organizational_roles, %i[event_id organizational_role_id],
              unique: true,
              name: 'index_event_org_roles_on_event_and_role'
  end
end
