class ConvertToManyToManyOrganizationalRoles < ActiveRecord::Migration[7.2]
  def up
    create_organizational_roles_table_if_needed
    create_junction_table
    migrate_existing_data
    remove_old_column
  end

  private

  def create_organizational_roles_table_if_needed
    return if table_exists?(:organizational_roles)

    create_table :organizational_roles do |t|
      t.string :name, null: false
      t.text :description
      t.timestamps
    end
    add_index :organizational_roles, :name, unique: true
  end

  def create_junction_table
    create_table :organizational_role_users do |t|
      t.references :user, null: false, foreign_key: true
      t.references :organizational_role, null: false, foreign_key: true
      t.timestamps
    end

    add_index :organizational_role_users, %i[user_id organizational_role_id],
              unique: true, name: 'index_org_role_users_on_user_and_role'
  end

  def migrate_existing_data
    User.where.not(organizational_role_id: nil).find_each do |user|
      execute <<-SQL
        INSERT INTO organizational_role_users (user_id, organizational_role_id, created_at, updated_at)
        VALUES (#{user.id}, #{user.organizational_role_id}, NOW(), NOW())
      SQL
    end
  end

  def remove_old_column
    remove_foreign_key :users, :organizational_roles
    remove_column :users, :organizational_role_id
  end

  public

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

    # NOTE: We don't drop organizational_roles table in down migration
    # because it may have been created by a different migration
  end
end
