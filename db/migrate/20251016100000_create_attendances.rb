class CreateAttendances < ActiveRecord::Migration[8.0]
  def change
    create_table :attendances do |t|
      t.references :user,  null: false, foreign_key: true
      t.references :event, null: false, foreign_key: true
      t.datetime :checked_in_at, null: false

      t.timestamps
    end

    add_index :attendances, %i[user_id event_id], unique: true
  end
end
