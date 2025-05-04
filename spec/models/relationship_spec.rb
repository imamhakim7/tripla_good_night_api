require 'rails_helper'

RSpec.describe Relationship, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:relationable) }
  end

  describe 'validations' do
    it { should validate_presence_of(:action_type) }
    it { should validate_inclusion_of(:action_type).in_array(Relationship::ALLOWED_ACTIONS) }
    it { should validate_presence_of(:user) }
    it { should validate_presence_of(:relationable) }
  end

  describe 'factories' do
    it 'has a valid factory' do
      expect(build :relationship).to be_valid
    end

    it 'has a valid factory with a user' do
      user = create :user
      relationship = build :relationship, user: user
      expect(relationship).to be_valid
    end

    it 'has a valid factory with a relationable' do
      relationable = create :user
      relationship = build :relationship, relationable: relationable
      expect(relationship).to be_valid
    end

    it 'has a valid factory with a follow action' do
      relationable = create :user
      relationship = build :relationship, relationable: relationable, action_type: 'follow'
      expect(relationship).to be_valid
    end
  end
end
