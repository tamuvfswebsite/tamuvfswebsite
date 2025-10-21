class CreateAdminPanelLogoPlacements < ActiveRecord::Migration[8.0]
  def change
    create_table :admin_panel_logo_placements do |t|
      t.references :sponsor, null: false, foreign_key: true
      t.string :page_name
      t.string :section
      t.boolean :displayed

      t.timestamps
    end
  end
end
