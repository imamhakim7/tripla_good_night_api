class Relationship < ApplicationRecord
  belongs_to :user
  belongs_to :relationable, polymorphic: true

  ALLOWED_ACTION_TYPES = %w[ follow ].freeze
  ALLOWED_RELATIONABLE_TYPES = {
    "user" => User
  }.freeze

  validates :action_type, presence: true, inclusion: { in: ALLOWED_ACTION_TYPES }
  validates :user, presence: true
  validates :relationable, presence: true
end
