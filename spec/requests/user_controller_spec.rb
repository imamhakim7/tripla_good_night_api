require 'rails_helper'

RSpec.describe "Api::UserController", type: :request do
  let(:user) { create :user }
  let(:other_user) { create :user }
  let(:headers) { authenticated_header(user) }

  before do
    # other_user gets 5 followers (including `user`)
    create_list :relationship, 4, relationable: other_user, action_type: :follow
    Relationship.create! user: user, relationable: other_user, action_type: :follow

    # user follows 3 other users + 1 above
    create_list(:user, 3).each do |target|
      Relationship.create!(user: user, relationable: target, action_type: :follow)
    end
  end

  describe "GET /api/my/profile" do
    it "returns the current user's profile" do
      get "/api/my/profile", headers: headers
      expect(response).to have_http_status(:ok)
      expect(json['data']['id']).to eq user.id.to_s
      expect(json['data']['attributes']['name']).to eq user.name
      expect(json['data']['attributes']['email']).to eq user.email
    end
  end

  describe "GET /api/users/:id" do
    it "returns another user's profile" do
      get "/api/users/#{other_user.id}", headers: headers
      expect(response).to have_http_status(:ok)
      expect(json['data']['id']).to eq other_user.id.to_s
      expect(json['data']['attributes']['name']).to eq other_user.name
      expect(json['data']['attributes']['email']).to eq other_user.email
    end
  end

  describe "GET /api/my/followers" do
    it "returns empty list (since current user has no followers)" do
      get "/api/my/followers", headers: headers
      expect(response).to have_http_status(:ok)
      expect(json['data']).to be_empty
    end
  end

  describe "GET /api/my/followings" do
    it "returns users the current user is following" do
      get "/api/my/followings", headers: headers
      expect(response).to have_http_status(:ok)
      expect(json['data'].size).to eq 4
    end
  end

  describe "GET /api/users/:id/followers" do
    it "returns followers of another user" do
      get "/api/users/#{other_user.id}/followers", headers: headers
      expect(response).to have_http_status(:ok)
      expect(json['data'].size).to eq 5
    end
  end

  describe "GET /api/users/:id/followings" do
    it "returns users another user is following (0 by default)" do
      get "/api/users/#{other_user.id}/followings", headers: headers
      expect(response).to have_http_status(:ok)
      expect(json['data']).to be_empty
    end
  end
end
