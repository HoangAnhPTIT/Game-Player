module Api
  class PlayersController < ApplicationController
    before_action :authorize_request
    before_action :admin_only, :except => [:show, :login]
    def index
      players = Player.all
      player_show = Array.new
      for player in players
          hash = to_show(player)
          player_show.push(hash)
      end
      render json: {players:player_show}
    end

    def create
      player = Player.new(player_params)
      if player.save
        player_show = to_show(player)
        render json: { player: player_show }
      else
        render json: { player: player.errors }, status: :unprocessable_entity
      end
    end

    def show
      player = Player.find(params[:id])
      player_show = to_show(player)
      render json: { player: player_show }
    end

    def update
      player = Player.find(params[:id])

      if player.update(player_params)
        player_show = to_show(player)
        render json: { player: player_show }
      else
        render json: { player: player.errors }, status: :unprocessable_entity
      end
    end

    def destroy
      player = Player.find(params[:id])
      player.destroy
      player_show = to_show(player)
      render json: { player: player_show }
    end

    def login
      username = params[:username]
      password = params[:password]
      player = Player.find_by(username: username, password: password)
      if player.present?
        player.update(status: true)
        render json: { message: 'Login success' }
        return
      end
      render json: { message: 'Username Or Password is wrong' } and return unless player.present?
    end

    def to_show(player)
      { 'id' => player.id, 'name' => player.fullname, 'point' => player.point,
        'wincount' => player.wincount, 'losecount' => player.losecount }
    end
    private

    def player_params
      params.permit(:username, :password, :fullname, :point, :wincount, :losecount, :status)
    end

    def admin_only
      render json: {message: 'Access denied'} and return if @current_user.roleid != 1
    end
  end
end
