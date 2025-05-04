FactoryBot.define do
  factory :relationship do
    user
    action_type { "follow" }
    association :relationable, factory: :user
  end
end
