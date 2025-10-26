class CreateResumeDownloads < ActiveRecord::Migration[8.0]
  def change
    create_table :resume_downloads do |t|
      t.references :user, null: false, foreign_key: true
      t.references :resume, null: false, foreign_key: true
      t.datetime :downloaded_at

      t.timestamps
    end
  end
end
