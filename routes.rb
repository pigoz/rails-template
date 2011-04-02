devise_for :users do
  get '/login'   => 'devise/sessions#new',       :as => :new_user_session
  post '/login'  => 'devise/sessions#create',    :as => :user_session
  get '/logout'  => 'devise/sessions#destroy',   :as => :destroy_user_session
  get '/signup'  => 'devise/registrations#new',   :as => :new_user_registration
end

root :to => "home#index"