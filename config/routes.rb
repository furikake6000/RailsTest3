Rails.application.routes.draw do

  get 'users/show'

  root 'static_pages#home'

  get '/auth/twitter/callback', to:'twitter_sessions#create'

  get '/logout', to:'twitter_sessions#destroy'
  get '/about', to:'static_pages#about'

  get '/quests', to:'quests#show'
  delete '/quests/destroy', to:'quests#destroy'

  get '/sandbox', to:'static_pages#sandbox'

end
