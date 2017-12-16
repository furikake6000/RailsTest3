Rails.application.routes.draw do

  root 'static_pages#home'
  resources :users, :only => [:show]

  get '/auth/twitter/callback', to:'twitter_sessions#create'
  get '/auth/failure', to:'twitter_sessions#failure'

  get '/ranking', to:'static_pages#ranking'

  get '/logout', to:'twitter_sessions#destroy'
  get '/about', to:'static_pages#about'
  get '/info', to:'static_pages#info'

  get '/report', to: 'users#report_history'
  post '/users/report', to:'users#report'

  get '/sandbox', to:'static_pages#sandbox'
  post '/sandbox/postimage', to: 'static_pages#postimage'

  get '/admin', to:'static_pages#admin'

end
