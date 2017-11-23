Rails.application.routes.draw do

  root 'static_pages#home'

  get '/auth/twitter/callback', to:'twitter_sessions#create'

  get '/logout', to:'twitter_sessions#destroy'
  get '/about', to:'static_pages#about'

  get '/quests', to:'quests#show'

end
