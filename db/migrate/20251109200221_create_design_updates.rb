class CreateDesignUpdates < ActiveRecord::Migration[7.0]
  def change
    create_table :design_updates do |t|
      t.string :title, null: false
      t.date :update_date, null: false

      t.timestamps
    end

    add_index :design_updates, :update_date
  end
end
