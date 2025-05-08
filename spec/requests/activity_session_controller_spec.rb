require 'rails_helper'

RSpec.describe "Api::ActivitySessionController", type: :request do
  let(:user) { create(:user) }
  let(:headers) { authenticated_header(user) }

  before do
    allow(Time).to receive(:current).and_return Time.current
  end

  describe "POST /api/act/:activity_type/clock_in" do
    [ 'sleep' ].each do |activity_type|
      it "creates a clock_in session for #{activity_type}" do
        post "/api/act/#{activity_type}/clock_in", headers: headers
        expect(response).to have_http_status(:created)

        expect(json["data"]["attributes"]["user-id"]).to eq user.id
        expect(json["data"]["attributes"]["activity-type"]).to eq activity_type
        expect(json["data"]["attributes"]["clock-in"]).to eq Time.current.iso8601(3)
        expect(json["data"]["attributes"]["clock-out"]).to be_nil
        expect(json["data"]["attributes"]["duration"]).to be_nil
        expect(json["data"]["relationships"]["user"]["data"]["id"]).to eq user.id.to_s
        expect(json["data"]["relationships"]["user"]["data"]["type"]).to eq "users"
      end
    end
  end

  describe "PATCH /api/act/:activity_type/clock_out" do
    [ 'sleep' ].each do |activity_type|
      it "clocks out latest ongoing #{activity_type} session" do
        clock_in_time = 1.hour.ago
        session = create(:activity_session, user: user, activity_type: activity_type, clock_in: clock_in_time, clock_out: nil)
        patch "/api/act/#{activity_type}/clock_out", headers: headers
        expect(response).to have_http_status(:ok)

        expect(json["data"]["id"]).to eq session.id.to_s
        expect(json["data"]["type"]).to eq "activity-sessions"
        expect(json["data"]["attributes"]["user-id"]).to eq user.id
        expect(json["data"]["attributes"]["activity-type"]).to eq activity_type
        expect(json["data"]["attributes"]["clock-in"]).to eq clock_in_time.iso8601(3)
        expect(json["data"]["attributes"]["clock-out"]).to eq Time.current.iso8601(3)
        expect(json["data"]["attributes"]["duration"]).to eq 3600
      end
    end
  end

  describe "PATCH /api/clock_out/:id" do
    it "clocks out by ID" do
      clock_in_time = 1.hour.ago
      session = create :activity_session, user: user, activity_type: "sleep", clock_in: clock_in_time, clock_out: nil
      patch "/api/clock_out/#{session.id}", headers: headers
      expect(response).to have_http_status(:ok)

      expect(json["data"]["id"]).to eq session.id.to_s
      expect(json["data"]["type"]).to eq "activity-sessions"
      expect(json["data"]["attributes"]["user-id"]).to eq user.id
      expect(json["data"]["attributes"]["activity-type"]).to eq "sleep"
      expect(json["data"]["attributes"]["clock-in"]).to eq clock_in_time.iso8601(3)
      expect(json["data"]["attributes"]["clock-out"]).to eq Time.current.iso8601(3)
      expect(json["data"]["attributes"]["duration"]).to eq 3600
    end
  end

  describe "GET /api/my/activities/:activity_type" do
    [ 'sleep' ].each do |activity_type|
      it "gets current_user sessions for #{activity_type}" do
        create :activity_session, user: user, activity_type: activity_type, clock_in: Time.current, clock_out: nil
        create :activity_session, user: user, activity_type: activity_type
        get "/api/my/activities/#{activity_type}", headers: headers

        expect(response).to have_http_status(:ok)
        expect(json["data"]).to be_an(Array)
        expect(json["data"].size).to eq 2
      end

      context "ongoing sessions" do
        it "returns ongoing sessions" do
          create :activity_session, user: user, activity_type: activity_type, clock_in: Time.current, clock_out: nil
          create :activity_session, user: user, activity_type: activity_type, clock_in: 1.hour.ago, clock_out: Time.current
          get "/api/my/activities/#{activity_type}?ongoing=true", headers: headers

          expect(response).to have_http_status(:ok)
          expect(json["data"]).to be_an(Array)
          expect(json["data"].size).to eq 1
          expect(json["data"].first["attributes"]["clock-out"]).to be_nil
        end
      end

      context "finished sessions" do
        it "returns finished sessions" do
          create :activity_session, user: user, activity_type: activity_type, clock_in: Time.current, clock_out: nil
          create :activity_session, user: user, activity_type: activity_type, clock_in: 1.hour.ago, clock_out: Time.current
          get "/api/my/activities/#{activity_type}?finished=1", headers: headers

          expect(response).to have_http_status(:ok)
          expect(json["data"]).to be_an(Array)
          expect(json["data"].size).to eq 1
          expect(json["data"].first["attributes"]["clock-out"]).not_to be_nil
        end

        it "returns sessions from the last week" do
          create :activity_session, user: user, activity_type: activity_type, clock_in: 5.days.ago, clock_out: Time.current
          create :activity_session, user: user, activity_type: activity_type, clock_in: 2.weeks.ago, clock_out: Time.current
          get "/api/my/activities/#{activity_type}?from_last_week=yes", headers: headers

          expect(response).to have_http_status(:ok)
          expect(json["data"]).to be_an(Array)
          expect(json["data"].size).to eq 1
          expect(json["data"].first["attributes"]["clock-in"]).to be >= 1.week.ago.iso8601(3)
        end
      end
    end
  end

  describe "GET /api/my/followers/activities/:activity_type" do
    [ 'sleep' ].each do |activity_type|
      it "gets my followers sessions for #{activity_type}" do
        follower = create :user
        follower.follow(user)
        create :activity_session, user: follower, activity_type: activity_type
        get "/api/my/followers/activities/#{activity_type}", headers: headers

        expect(response).to have_http_status(:ok)
        expect(json["data"]).to be_an(Array)
      end
    end
  end

  describe "GET /api/my/followings/activities/:activity_type" do
    [ 'sleep' ].each do |activity_type|
      it "gets followings sessions for #{activity_type}" do
        following = create :user
        user.follow(following)
        create :activity_session, user: following, activity_type: activity_type
        get "/api/my/followings/activities/#{activity_type}", headers: headers

        expect(response).to have_http_status(:ok)
        expect(json["data"]).to be_an(Array)
      end
    end
  end

  describe "GET /api/users/:id/activities/:activity_type" do
    [ 'sleep' ].each do |activity_type|
      it "gets specific user's sessions for #{activity_type}" do
        other = create :user
        create :activity_session, user: other, activity_type: activity_type
        get "/api/users/#{other.id}/activities/#{activity_type}", headers: headers

        expect(response).to have_http_status(:ok)
        expect(json["data"]).to be_an(Array)
      end
    end
  end

  describe "GET /api/users/:id/followers/activities/:activity_type" do
    [ 'sleep' ].each do |activity_type|
      it "gets followers of user sessions for #{activity_type}" do
        other = create :user
        follower = create :user
        follower.follow(other)
        create :activity_session, user: follower, activity_type: activity_type
        get "/api/users/#{other.id}/followers/activities/#{activity_type}", headers: headers

        expect(response).to have_http_status(:ok)
        expect(json["data"]).to be_an(Array)
      end
    end
  end

  describe "GET /api/users/:id/followings/activities/:activity_type" do
    [ 'sleep' ].each do |activity_type|
      it "gets followings of user sessions for #{activity_type}" do
        other = create :user
        following = create :user
        following.follow(other)
        create(:activity_session, user: following, activity_type: activity_type)
        get "/api/users/#{other.id}/followings/activities/#{activity_type}", headers: headers

        expect(response).to have_http_status(:ok)
        expect(json["data"]).to be_an(Array)
      end
    end
  end
end
