class Relationship < ApplicationRecord
  belongs_to :user
  belongs_to :relationable, polymorphic: true

  ALLOWED_ACTIONS = %w[ follow ].freeze

  validates :action_type, presence: true, inclusion: { in: ALLOWED_ACTIONS }
  validates :user, presence: true
  validates :relationable, presence: true
end
