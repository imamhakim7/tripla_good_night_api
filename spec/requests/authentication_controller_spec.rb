require 'rails_helper'

RSpec.describe 'Api::AuthenticationController', type: :request do
  describe 'POST /api/auth/login' do
    let(:user) { create :user }
    let(:valid_credentials) { { email: user.email, password: user.password } }

    context 'with valid credentials' do
      it 'returns a JWT token' do
        post '/api/auth/login', params: valid_credentials
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['access_token']).to be_present
      end
    end

    context 'with invalid credentials' do
      it 'returns unauthorized status with invalid email' do
        post '/api/auth/login', params: { email: 'wrong@example.com', password: 'password123' }
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to eq 'Invalid credentials'
      end

      it 'returns unauthorized status with invalid password' do
        post '/api/auth/login', params: { email: 'test@example.com', password: 'wrong_password' }
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to eq 'Invalid credentials'
      end

      it 'returns unauthorized status with blank password' do
        post '/api/auth/login', params: { email: 'test@example.com', password: '' }
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to eq 'Invalid credentials'
      end
    end
  end

  describe 'POST /api/auth/refresh' do
    let(:user) { create :user }

    context 'with valid token' do
      it 'returns a new JWT token' do
        payload = { id: user.id, email: user.email }
        refresh_token = AuthorizeApiRequest.encoded_auth_token(payload, expires_in: 7.days.from_now)
        user.update(refresh_token: refresh_token)

        post '/api/auth/refresh', headers: { 'Authorization' => "Bearer #{refresh_token}" }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['access_token']).to be_present
      end
    end

    context 'with expired token' do
      it 'returns expired token status' do
        payload = { id: user.id, email: user.email }
        refresh_token = AuthorizeApiRequest.encoded_auth_token(payload, expires_in: 1.second.ago)
        user.update(refresh_token: refresh_token)

        post '/api/auth/refresh', headers: { 'Authorization' => "Bearer #{refresh_token}" }
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to eq 'Token has expired'
      end
    end

    context 'with invalid token' do
      it 'returns invalid token status' do
        post '/api/auth/refresh', headers: { 'Authorization' => 'Bearer invalid_token' }
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to eq 'Invalid token'
      end
    end

    context 'with missing token' do
      it 'returns unauthorized status' do
        post '/api/auth/refresh', headers: {}
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to eq 'Unauthorized'
      end
    end
  end

  describe 'POST /api/auth/logout' do
    let(:user) { create :user }

    context 'with valid token' do
      it 'logs out the user' do
        payload = { id: user.id, email: user.email }
        refresh_token = AuthorizeApiRequest.encoded_auth_token(payload, expires_in: 7.days.from_now)
        user.update(refresh_token: refresh_token)

        post '/api/auth/logout', headers: { 'Authorization' => "Bearer #{refresh_token}" }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['message']).to eq 'Logged out successfully'
        expect(user.reload.refresh_token).to be_nil
      end
    end
  end
end
