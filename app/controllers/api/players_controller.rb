module Api
  class PlayersController < ApplicationController
    include Pagy::Backend

    before_action :authorize_request
    before_action :admin_only, except: %i[show login]
    def index
      cur_page = params[:cur_page]
      players = Player.all
      player_show = []
      players.each do |player|
        hash = to_show(player)
        player_show.push(hash)
      end

      @pagy, @players = pagy_array(player_show, items: 2, page: cur_page)
      render json: { players: @players }
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
      render json: { message: 'Access denied' } and return if @current_user.roleid != 1
    end
  end
end