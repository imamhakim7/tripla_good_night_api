class User < ApplicationRecord
  has_secure_password

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  has_many :relationships, dependent: :destroy
  has_many :activity_sessions, dependent: :destroy

  has_many :following_relations, -> { where(action_type: :follow) }, class_name: "Relationship", foreign_key: "user_id"
  has_many :followings, through: :following_relations, source: :relationable, source_type: "User"

  has_many :follower_relations, -> { where(action_type: :follow) }, class_name: "Relationship", as: :relationable
  has_many :followers, through: :follower_relations, source: :user

  def follow(user)
      errors.add(:base, "You cannot follow yourself.") if relation_to_one_self?(user)
      errors.add(:base, "You are already following this user.") if existing_relationship?(user)
      return if errors.any?
      relationships.create(relationable: user, action_type: "follow")
  end

  def unfollow(user)
    errors.add(:base, "You are not following this user.") if !existing_relationship?(user)
    return if errors.any?
    relationships.find_by(relationable: user, action_type: "follow")&.destroy
  end

  private

  def relation_to_one_self?(user)
    self == user
  end

  def existing_relationship?(user)
    relationships.exists?(relationable: user, action_type: "follow")
  end
end
