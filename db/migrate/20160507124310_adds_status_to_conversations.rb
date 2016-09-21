class AddsStatusToConversations < ActiveRecord::Migration
  def change
    add_column :conversations, :status, :integer, default: 0
  end
end
