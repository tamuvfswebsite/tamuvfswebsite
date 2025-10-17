class AddScopeExclusionPlaceholders < ActiveRecord::Migration[8.0]
  def change
    # Messaging placeholder
    create_table :messages, id: :uuid do |t|
      t.uuid :sender_id
      t.uuid :receiver_id
      t.text :body
      t.datetime :created_at
    end

    # Payments placeholder
    create_table :payments, id: :uuid do |t|
      t.uuid :user_id
      t.decimal :amount
      t.string :status
      t.datetime :created_at
    end

    # Multi-language/i18n placeholder
    create_table :translations, id: :uuid do |t|
      t.string :locale
      t.string :key
      t.text :value
    end

    # Image processing placeholder
    create_table :images, id: :uuid do |t|
      t.string :url
      t.string :processed_variant
      t.datetime :created_at
    end
  end
end


