FactoryBot.define do
  factory :activity_session do
    user
    activity_type { "sleep" }
    clock_in { 2.hours.ago }
    clock_out { 1.hours.ago }
  end
end
