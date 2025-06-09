require 'rails_helper'

# Auth APIのテスト
RSpec.describe 'Auth API', type: :request do
  describe 'POST /api/auth' do
    context 'with valid params' do
      let(:valid_params) do
        {
          email: 'test@example.com',
          password: 'password123',
          password_confirmation: 'password123',
          name: 'Test User'
        }
      end
            
      it 'creates a new user and returns auth tokens' do
          post '/api/auth', params: valid_params, as: :json
          expect(response).to have_http_status(:ok)
          expect(response.headers).to include('access-token')
          expect(response.headers).to include('token-type')
          expect(response.headers).to include('client')
          expect(response.headers).to include('expiry')
          
          json = JSON.parse(response.body)
          expect(json['data']['email']).to eq(valid_params[:email])
      end
    end
        
    context 'with invalid params' do
      let(:invalid_params) do
        {
          email: 'invalid_email',
          password: 'short',
          password_confirmation: 'short_confirmation',
        }
      end

      it 'returns errors' do
        post '/api/auth', params: invalid_params, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors']).to be_present
        expect(json['errors']['email']).to include('is not an email')
        expect(json['errors']['password']).to include('is too short (minimum is 6 characters)')
        expect(json['errors']['password_confirmation']).to include("doesn't match Password")
        expect(json['errors']['name']).to include("can't be blank")
      end
    end
  end
    
  describe 'POST /api/auth/sign_in' do
    let!(:user) { FactoryBot.create(:user, email: 'test@example.com', password: 'password123') }

    it 'authenticates the user and returns tokens' do
      post '/api/auth/sign_in', params: { email: user.email, password: 'password123' }, as: :json

      expect(response).to have_http_status(:ok)
      expect(response.headers).to include('access-token')
      expect(response.headers).to include('token-type')
      expect(response.headers).to include('client')
      expect(response.headers).to include('expiry')
      expect(response.headers['uid']).to eq(user.email)
    end
  end
  
  describe 'DELETE /api/auth/sign_out' do
    let!(:user) { FactoryBot.create(:user, email: 'test@example.com', password: 'password123') }

    before do
      post '/api/auth/sign_in', params: { email: user.email, password: 'password123' }, as: :json
    end

    it 'signs out the user and invalidates the tokens' do
      delete '/api/auth/sign_out', headers: { 'access-token' => response.headers['access-token'], 'client' => response.headers['client'], 'uid' => response.headers['uid'] }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('success')
    end
  end
end