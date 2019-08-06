Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get :alive, to: 'application#alive'
      get :ping, to: 'application#ping'
      get :user_info, to: 'users#user_info'

      resources :users, except: %i(new edit) do
        member do
          get :check_name
        end
      end
      post :login, to: 'users#login'
      post :logout, to: 'users#logout'

      resources :money_records, except: %i(new edit show) do
        collection do
          get :options
          get :static
          get :static_tag_percent
        end
      end
    end
  end

end
