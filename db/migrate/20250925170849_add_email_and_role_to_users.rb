class AddEmailAndRoleToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :email, :string
    add_column :users, :role, :string
  end
end
