class AddGoogleAvatarUrlToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :google_avatar_url, :string
  end
end
