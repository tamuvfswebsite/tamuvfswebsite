class CreateRoleApplications < ActiveRecord::Migration[8.0]
  def change
    create_table :role_applications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :org_role
      t.text :essay

      t.timestamps
    end
  end
end
