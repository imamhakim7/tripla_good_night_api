require 'rails_helper'

RSpec.describe 'Relationship Controller', type: :request do
  let(:user) { create(:user) }
  let(:headers) { authenticated_header(user) }

  describe 'POST /api/do' do
    let(:relationable) { create(:user) }

    context 'with valid relationable' do
      [ 'follow' ].each do |action_type|
        it "creates a new relationship with action_type #{action_type}" do
          post "/api/do/#{action_type}/#{relationable.class.name}/#{relationable.id}", headers: headers
          expect(response).to have_http_status(:created)
        end
      end
    end

    context 'with invalid path' do
      [ 'follow' ].each do |action_type|
        it "returns an error when action_type #{action_type} is missing" do
          post "/api/do/#{relationable.class.name}/#{relationable.id}", headers: headers
          expect(response).to have_http_status(:not_found)
        end

        it "returns an error when relationable_id is missing" do
          post "/api/do/#{action_type}/#{relationable.class.name}", headers: headers
          expect(response).to have_http_status(:not_found)
        end

        it "returns an error when relationable_type is missing" do
          post "/api/do/#{action_type}/#{relationable.id}", headers: headers
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when the relationship already exists' do
      [ 'follow' ].each do |action_type|
        before do
          user.relationships.create(action_type: action_type, relationable: relationable)
        end

        it "returns a status of already_exists for action_type #{action_type}" do
          post "/api/do/#{action_type}/#{relationable.class.name}/#{relationable.id}", headers: headers
          expect(response).to have_http_status(:ok)
        end

        it 'does not create a duplicate relationship' do
          expect {
            post "/api/do/#{action_type}/#{relationable.class.name}/#{relationable.id}", headers: headers
          }.not_to change(Relationship, :count)
        end
      end
    end

    context 'when the user is not authenticated' do
      [ 'follow' ].each do |action_type|
        it "returns an unauthorized status for action_type #{action_type}" do
          post "/api/do/#{action_type}/#{relationable.class.name}/#{relationable.id}"
          expect(response).to have_http_status(:unauthorized)
          expect(JSON.parse(response.body)['error']).to eq('Unauthorized')
        end
      end
    end
  end

  describe 'DELETE /api/do' do
    let(:relationable) { create(:user) }

    context 'with valid relationable' do
      [ 'follow' ].each do |action_type|
        it "deletes the relationship with action_type #{action_type}" do
          user.relationships.create(action_type: action_type, relationable: relationable)
          delete "/api/do/#{action_type}/#{relationable.class.name}/#{relationable.id}", headers: headers
          expect(response).to have_http_status(:no_content)
        end
      end
    end

    context 'with invalid path' do
      [ 'follow' ].each do |action_type|
        it "returns an error when action_type #{action_type} is missing" do
          delete "/api/do/#{relationable.class.name}/#{relationable.id}", headers: headers
          expect(response).to have_http_status(:not_found)
        end

        it "returns an error when relationable_id is missing" do
          delete "/api/do/#{action_type}/#{relationable.class.name}", headers: headers
          expect(response).to have_http_status(:not_found)
        end

        it "returns an error when relationable_type is missing" do
          delete "/api/do/#{action_type}/#{relationable.id}", headers: headers
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when the relationship does not exist' do
      [ 'follow' ].each do |action_type|
        it "returns a status of not_found for action_type #{action_type}" do
          delete "/api/do/#{action_type}/#{relationable.class.name}/#{relationable.id}", headers: headers
          expect(response).to have_http_status(:not_found)
        end

        it 'does not change the relationship count' do
          expect {
            delete "/api/do/#{action_type}/#{relationable.class.name}/#{relationable.id}", headers: headers
          }.not_to change(Relationship, :count)
        end
      end
    end

    context 'when the user is not authenticated' do
      [ 'follow' ].each do |action_type|
        it "returns an unauthorized status for action_type #{action_type}" do
          delete "/api/do/#{action_type}/#{relationable.class.name}/#{relationable.id}"
          expect(response).to have_http_status(:unauthorized)
          expect(JSON.parse(response.body)['error']).to eq('Unauthorized')
        end
      end
    end
  end
end
