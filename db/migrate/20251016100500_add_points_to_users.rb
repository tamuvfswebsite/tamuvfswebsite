class AddPointsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :points, :integer, null: false, default: 0
  end
end
