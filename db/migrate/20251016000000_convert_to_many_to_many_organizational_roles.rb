class ConvertToManyToManyOrganizationalRoles < ActiveRecord::Migration[7.2]
  def up
    # Create the junction table
    create_table :organizational_role_users do |t|
      t.references :user, null: false, foreign_key: true
      t.references :organizational_role, null: false, foreign_key: true
      t.timestamps
    end

    # Add unique index to prevent duplicate assignments
    add_index :organizational_role_users, [:user_id, :organizational_role_id],
              unique: true, name: 'index_org_role_users_on_user_and_role'

    # Migrate existing data
    User.where.not(organizational_role_id: nil).find_each do |user|
      execute <<-SQL
        INSERT INTO organizational_role_users (user_id, organizational_role_id, created_at, updated_at)
        VALUES (#{user.id}, #{user.organizational_role_id}, NOW(), NOW())
      SQL
    end

    # Remove the old foreign key and column
    remove_foreign_key :users, :organizational_roles
    remove_column :users, :organizational_role_id
  end

  def down
    # Add the column back
    add_column :users, :organizational_role_id, :bigint
    add_foreign_key :users, :organizational_roles
    add_index :users, :organizational_role_id

    # Migrate data back (taking the first organizational role if multiple exist)
    execute <<-SQL
      UPDATE users
      SET organizational_role_id = org_role_users.organizational_role_id
      FROM (
        SELECT DISTINCT ON (user_id) user_id, organizational_role_id
        FROM organizational_role_users
        ORDER BY user_id, created_at
      ) AS org_role_users
      WHERE users.id = org_role_users.user_id
    SQL

    # Drop the junction table
    drop_table :organizational_role_users
  end
end
