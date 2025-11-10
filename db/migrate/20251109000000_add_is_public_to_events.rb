class AddIsPublicToEvents < ActiveRecord::Migration[8.0]
  def change
    return if column_exists?(:events, :is_public)

    add_column :events, :is_public, :boolean, default: false, null: false
  end
end
