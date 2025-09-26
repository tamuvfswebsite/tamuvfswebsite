class DropPostsAndCommentsTables < ActiveRecord::Migration[8.0]
  def up
    drop_table :comments if table_exists?(:comments)
    drop_table :posts if table_exists?(:posts)
  end

  def down
    # NOTE: This is intentionally left empty as we don't want to recreate these tables
    # If you need to recreate them, you'll need to look at the original migration files
    raise ActiveRecord::IrreversibleMigration, 'Cannot recreate posts and comments tables'
  end
end
