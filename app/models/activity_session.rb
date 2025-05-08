class ActivitySession < ApplicationRecord
  belongs_to :user

  ALLOWED_ACTIVITY_TYPES = %w[sleep].freeze

  validates :activity_type, presence: true
  validates :activity_type, inclusion: { in: ALLOWED_ACTIVITY_TYPES }
  validates :clock_in, presence: true

  validate :clock_out_after_clock_in

  scope :ongoing, -> { where(clock_out: nil) }
  scope :finished, -> { where("clock_in is not null and clock_out is not null") }

  scope :from_last_week, -> { where("clock_in >= ?", 1.week.ago) }
  scope :sleep_sessions, -> { where(activity_type: "sleep") }

  def duration
    return nil unless clock_in && clock_out
    (clock_out - clock_in).to_i
  end

  private

  def clock_out_after_clock_in
    return unless clock_in && clock_out
    errors.add(:clock_out, "must be after clock in") if clock_out <= clock_in
  end
end
