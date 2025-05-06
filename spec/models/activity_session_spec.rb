require 'rails_helper'

RSpec.describe ActivitySession, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
  end

  describe "validations" do
    it { should validate_presence_of(:activity_type) }
    it { should validate_inclusion_of(:activity_type).in_array(ActivitySession::ALLOWED_ACTIVITY_TYPES) }
    it { should validate_presence_of(:clock_in) }

    context "when clock_out within clock_in" do
      it "is invalid" do
        activity_session = ActivitySession.new(clock_in: Time.current, clock_out: Time.current - 1.hour)
        expect(activity_session.valid?).to be_falsey
        expect(activity_session.errors[:clock_out]).to include("must be after clock in")
      end
    end
  end

  describe "instance methods" do
    let(:activity_session) { create :activity_session, clock_in: 2.hours.ago, clock_out: 1.hour.ago }

    describe "#duration" do
      it "returns the duration of the session" do
        expect(activity_session.duration).to eq 3600
      end

      it "returns nil if clock_in or clock_out is nil" do
        activity_session.update(clock_out: nil)
        expect(activity_session.duration).to be_nil
      end
    end
  end

  describe "scopes" do
    let(:user) { create :user }
    let!(:activity_session1) { create :activity_session, user: user, clock_in: 1.day.ago, clock_out: nil }
    let!(:activity_session2) { create :activity_session, user: user, clock_in: 5.days.ago, clock_out: 1.day.ago }
    let!(:activity_session3) { create :activity_session, user: user, clock_in: 2.weeks.ago, clock_out: 2.days.ago }

    describe ".incomplete" do
      it "returns sessions with nil clock_in or clock_out" do
        expect(ActivitySession.incomplete).to include(activity_session1)
        expect(ActivitySession.incomplete).not_to include(activity_session2)
        expect(ActivitySession.incomplete).not_to include(activity_session3)
      end
    end

    describe ".finished" do
      it "returns sessions with both clock_in and clock_out" do
        expect(ActivitySession.finished).not_to include(activity_session1)
        expect(ActivitySession.finished).to include(activity_session2)
        expect(ActivitySession.finished).to include(activity_session3)
      end
    end

    describe ".from_last_week" do
      it "returns sessions from the last week" do
        expect(ActivitySession.from_last_week).to include(activity_session1)
        expect(ActivitySession.from_last_week).to include(activity_session2)
        expect(ActivitySession.from_last_week).not_to include(activity_session3)
      end

      it "does not return sessions older than a week" do
        activity_session3.update(clock_in: 2.weeks.ago, clock_out: 1.week.ago)
        expect(ActivitySession.from_last_week).not_to include(activity_session3)
      end
    end

    describe ".sleep_sessions" do
      it "returns sessions with activity_type 'sleep'" do
        activity_session1.update(activity_type: "sleep")
        expect(ActivitySession.sleep_sessions).to include(activity_session1)
      end
    end
  end
end
