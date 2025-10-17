class AddPublishedToEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :events, :is_published, :boolean, null: false, default: true
  end
end
