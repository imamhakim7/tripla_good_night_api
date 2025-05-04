class RelationshipSerializer < ActiveModel::Serializer
  attributes :id
  attribute :action_type
  belongs_to :user
  belongs_to :relationable, polymorphic: true
end
