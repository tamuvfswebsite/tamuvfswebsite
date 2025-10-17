class AddScopeExclusionPlaceholders < ActiveRecord::Migration[8.0]
  def change
    create_messages
    create_payments
    create_translations
    create_images
  end

  private

  def create_messages
    create_table :messages, id: :uuid do |t|
      t.uuid :sender_id
      t.uuid :receiver_id
      t.text :body
      t.datetime :created_at
    end
  end

  def create_payments
    create_table :payments, id: :uuid do |t|
      t.uuid :user_id
      t.decimal :amount
      t.string :status
      t.datetime :created_at
    end
  end

  def create_translations
    create_table :translations, id: :uuid do |t|
      t.string :locale
      t.string :key
      t.text :value
    end
  end

  def create_images
    create_table :images, id: :uuid do |t|
      t.string :url
      t.string :processed_variant
      t.datetime :created_at
    end
  end
end
