Rails.application.routes.draw do
  # Swagger API documentation
  mount Rswag::Api::Engine => '/api-docs'
  mount Rswag::Ui::Engine => '/api-docs'

  # API routes
  scope '/api' do
    mount_devise_token_auth_for 'User', at: 'auth'
    resources :schedules, except: [:new, :edit]
  end
end
