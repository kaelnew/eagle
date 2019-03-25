Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get :alive, to: 'application#alive'

      resources :users, except: %i(new edit show)
      post :login, to: 'users#login'
      post :logout, to: 'users#logout'
    end
  end

end
