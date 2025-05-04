require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:relationships).dependent(:destroy) }

    it { should have_many(:follower_relations).class_name('Relationship') }
    it { should have_many(:followers).through(:follower_relations).source(:user) }
    it { should have_many(:following_relations).class_name('Relationship').with_foreign_key('user_id') }
    it { should have_many(:followings).through(:following_relations).source(:relationable).class_name('User') }
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      user = create :user
      expect(user).to be_valid
    end

    it 'is invalid without a name' do
      user = build :user, name: nil
      expect(user).to_not be_valid
      expect(user.errors[:name]).to include("can't be blank")
    end

    it 'is invalid without an email' do
      user = build :user, email: nil
      expect(user).to_not be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end

    it 'is invalid with a duplicate email' do
      User.create_or_find_by(email: 'test@example.com', name: 'Test User', password: 'password123')
      user = build :user, email: 'test@example.com'
      expect(user).to_not be_valid
      expect(user.errors[:email]).to include('has already been taken')
    end

    it 'is invalid with an invalid email format' do
      user = build :user, email: 'invalid_email'
      expect(user).to_not be_valid
      expect(user.errors[:email]).to include('is invalid')
    end

    it 'has a secure password' do
      user = create :user, password: 'password123'
      expect(user.authenticate('password123')).to eq(user)
      expect(user.authenticate('wrong_password')).to be_falsey
    end
  end

  describe '#follow' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }

    it 'follows another user' do
      expect { user.follow(other_user) }.to change { user.followings.count }.by(1)
      expect(user.followings).to include(other_user)
    end

    it 'does not follow the same user multiple times' do
      user.follow(other_user)
      expect { user.follow(other_user) }.not_to change { user.followings.count }
    end

    it 'cannot follow oneself' do
      user.follow(user)
      expect(user.errors[:base]).to include('You cannot follow yourself.')
    end
  end

  describe '#unfollow' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }

    before do
      user.follow(other_user)
    end

    it 'unfollows another user' do
      expect { user.unfollow(other_user) }.to change { user.followings.count }.by(-1)
      expect(user.followings).not_to include(other_user)
    end

    it 'does not raise an error if not following the user' do
      expect { user.unfollow(create(:user)) }.not_to raise_error
      expect(user.errors[:base]).to include('You are not following this user.')
    end
  end

  describe '#followers' do
    let(:user) { create(:user) }
    let(:follower) { create(:user) }

    before do
      user.follow(follower)
      follower.follow(user)
    end

    it 'returns the followers of the user' do
      expect(user.followers).to include(follower)
    end

    it 'does not include users who are not followers' do
      other_user = create(:user)
      expect(user.followers).not_to include(other_user)
    end
  end

  describe '#followings' do
    let(:user) { create(:user) }
    let(:following) { create(:user) }

    before { user.follow(following) }

    it 'returns the users that the user is following' do
      expect(user.followings).to include(following)
    end

    it 'does not include users who are not being followed' do
      other_user = create(:user)
      expect(user.followings).not_to include(other_user)
    end
  end
end
