class Message < ActiveRecord::Base
  belongs_to :conversation

  validates :body, presence: true
  validates :received_at, presence: true
  validates :raw_data, presence: true
  validates :conversation, presence: true

  scope :valid, -> { where(valid_message: true) }
  scope :not_validated, -> { where(valid_message: nil) }
end
