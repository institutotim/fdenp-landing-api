class CreatesConversationStructure < ActiveRecord::Migration
  def change
    create_table :conversations do |t|
      t.string :number
      t.datetime :last_received_message_at

      t.timestamps
    end

    create_table :messages do |t|
      t.integer :conversation_id
      t.integer :step
      t.boolean :valid_message
      t.string :broker_id
      t.text :body
      t.datetime :received_at
      t.json :raw_data

      t.timestamps
    end

    add_index :messages, [:conversation_id]
  end
end
