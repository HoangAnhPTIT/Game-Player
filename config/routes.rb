Rails.application.routes.draw do
  namespace 'api' do
    resources :players
    resources :games
    resources :users
    post '/games/:gameid/score', to: 'games#score'
    delete '/games/do/:gameid/:act', to: 'games#reset_point'
    put '/games/:gameid/end', to: 'games#end_game'
    get '/leaderboard', to: 'games#leaderboard'
    post '/auth/login', to: 'authentication#login'
    post '/players/login', to: 'players#login'
    get '/*a', to: 'application#not_found'
  end
end
