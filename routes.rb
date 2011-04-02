devise_for :users do
  get  '/signin'   => 'devise/sessions#new',       :as => :new_user_session
  post '/signin'   => 'devise/sessions#create',    :as => :user_session
  get  '/signout'  => 'devise/sessions#destroy',   :as => :destroy_user_session
  get  '/signup'   => 'devise/registrations#new',  :as => :new_user_registration
end

root :to => "home#index"