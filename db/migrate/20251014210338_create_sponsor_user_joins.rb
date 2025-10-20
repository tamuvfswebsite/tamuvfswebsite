class CreateSponsorUserJoins < ActiveRecord::Migration[8.0]
  def change
    create_table :sponsor_user_joins do |t|
      t.references :user, null: false, foreign_key: true
      t.references :sponsor, null: false, foreign_key: true

      t.timestamps
    end
  end
end
