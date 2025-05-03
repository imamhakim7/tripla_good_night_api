require 'rails_helper'

RSpec.describe User, type: :model do
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
      User.create_or_find_by(email: 'test@example.com')
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
end
