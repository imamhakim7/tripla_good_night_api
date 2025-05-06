class ActivitySessionSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :activity_type, :clock_in, :clock_out, :duration
  belongs_to :user
end
