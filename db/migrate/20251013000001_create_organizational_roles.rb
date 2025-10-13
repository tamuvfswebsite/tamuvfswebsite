class CreateOrganizationalRoles < ActiveRecord::Migration[7.2]
  def change
    create_table :organizational_roles do |t|
      t.string :name, null: false
      t.text :description

      t.timestamps
    end

    add_index :organizational_roles, :name, unique: true
  end
end
