class CreateEventRsvps < ActiveRecord::Migration[8.0]
  def change
    create_table :event_rsvps, id: :uuid do |t|
      t.references :event, null: false, foreign_key: true, type: :bigint
      t.references :user,  null: false, foreign_key: true, type: :bigint
      t.string :status, null: false, default: 'yes' # yes/no/maybe
      t.timestamps
    end

    add_index :event_rsvps, %i[event_id user_id], unique: true
  end
end
