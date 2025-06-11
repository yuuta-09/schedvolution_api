require 'rails_helper'
require 'swagger_helper'

# Auth APIのテスト
RSpec.describe 'Authentication API', type: :request do
  #======================================
  # ユーザ登録 (POST /api/auth)
  #======================================
  path '/api/auth' do
    post('ユーザ登録(Sign Up)') do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      
      # リクエストBODYのスキーマ
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string, example: '山田太郎' },
          email: { type: :string, format: 'email', example: 'test@example.com' },
          password: { type: :string, example: 'password123' },
          password_confirmation: { type: :string, example: 'password123' },
        },
        required: ['name', 'email', 'password']
      }
      
      # 正常なレスポンス
      response(200, '成功') do
        # 成功時のレスポンスBodyのスキーマを定義
        schema type: :object,
                properties: {
                  data: {
                    type: :object,
                    properties: {
                      email: { type: :string, format: 'email', example: 'test@example.com' },
                      provider: { type: :string, example: 'email' },
                      uid: { type: :string, example: '1' },
                      id: { type: :integer, example: 1 },
                      allow_password_change: { type: :boolean, example: false },
                      name: { type: :string, example: '山田太郎' },
                      is_active: { type: :boolean, example: true },
                      is_free_user: { type: :boolean, example: true },
                      created_at: { type: :string, format: 'date-time', example: '2023-06-01T12:00:00Z' },
                      updated_at: { type: :string, format: 'date-time', example: '2023-06-01T12:00:00Z' },
                    }
                  }
                }
        header 'access-token', type: :string, description: 'Access Token'
        header 'token-type', type: :string, description: 'Token Type(Bearer)'
        header 'client', type: :string, description: 'Client ID'
        header 'expiry', type: :string, description: 'Token Expiry Time'
        header 'uid', type: :string, description: 'User ID(email)'
        
        # テスト実行用のデータ
        let(:user) { attributes_for(:user) }
        run_test!
      end
      
      # 異常なレスポンス
      response(422, 'バリデーションエラー') do
        schema type: :object,
               properties: {
                 status: { type: :string, example: 'error' },
                 data: {
                   type: :object,
                   properties: {
                     id: { type: :null },
                     provider: { type: :string, example: 'email' },
                     uid: { type: :string, example: '' },
                     allow_password_change: { type: :boolean, example: false },
                     name: { type: :string, example: 'テストユーザー' },
                     email: { type: :string, example: 'testexample.com' },
                     is_active: { type: :boolean, example: true },
                     is_free_user: { type: :boolean, example: true },
                     created_at: { type: :null },
                     updated_at: { type: :null }
                   }
                 },
                 errors: {
                   type: :object,
                   properties: {
                     email: {
                       type: :array,
                       items: { type: :string },
                       example: ['is not an email']
                     },
                     full_messages: {
                       type: :array,
                       items: { type: :string },
                       example: ['Email is not an email']
                     }
                   }
                 }
               },
               required: ['status', 'data', 'errors']
               
        let(:user) { attributes_for(:user, email: 'testexample.com') } # 無効なメールアドレス
        run_test!
      end
    end
  end
  
  #======================================
  # ユーザログイン (POST /api/auth/sign_in)
  #======================================
  path '/api/auth/sign_in' do
    post('ログイン（Sign In）') do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, example: 'test@example.com' },
          password: { type: :string, example: 'password123' }
        },
        required: ['email', 'password']
      }

      # 正常系
      response(200, '成功') do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     id: { type: :integer, example: 1 },
                     email: { type: :string, format: :email },
                     name: { type: :string, example: 'Test User' },
                     uid: { type: :string, example: 'test@example.com' },
                     provider: { type: :string, example: 'email' },
                     is_active: { type: :boolean },
                     is_free_user: { type: :boolean },
                     created_at: { type: :string, format: 'date-time' },
                     updated_at: { type: :string, format: 'date-time' }
                   }
                 }
               }

        # トークン系ヘッダ
        header 'access-token', schema: { type: :string }
        header 'token-type', schema: { type: :string, example: 'Bearer' }
        header 'client', schema: { type: :string }
        header 'expiry', schema: { type: :string }
        header 'uid', schema: { type: :string }

        let!(:user) { create(:user, email: 'test@example.com', password: 'password123', password_confirmation: 'password123') }
        let(:credentials) do
          {
            email: 'test@example.com',
            password: 'password123'
          }
        end

        run_test!
      end

      # 異常系（パスワード違い）
      response(401, 'Unauthorized') do
        schema type: :object,
               properties: {
                 errors: {
                   type: :array,
                   items: { type: :string },
                   example: ['Invalid login credentials. Please try again.']
                 }
               }

        let(:credentials) do
          {
            email: 'test@example.com',
            password: 'wrongpassword'
          }
        end

        let!(:user) { create(:user, email: 'test@example.com', password: 'password123', password_confirmation: 'password123') }

        run_test!
      end
    end
  end
  
  #======================================
  # ユーザログアウト (DELETE /api/auth/sign_out)
  #======================================
  path '/api/auth/sign_out' do
    delete('ユーザーログアウト') do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'

      # 認証ヘッダー
      parameter name: 'access-token', in: :header, type: :string, required: true
      parameter name: 'client', in: :header, type: :string, required: true
      parameter name: 'uid', in: :header, type: :string, required: true

      response(200, '成功') do
        let(:user) { create(:user) }

        # ログインしてトークンを取得
        let(:auth_headers) do
          post '/api/auth/sign_in', params: {
            email: user.email,
            password: user.password
          }
          response.headers.slice('access-token', 'client', 'uid')
        end

        let('access-token') { auth_headers['access-token'] }
        let('client')       { auth_headers['client'] }
        let('uid')          { auth_headers['uid'] }

        run_test!
      end

      response(404, 'ログインしていない or トークン無効') do
        let('access-token') { 'invalid' }
        let('client')       { 'invalid' }
        let('uid')          { 'invalid@example.com' }

        run_test!
      end
    end
  end
end