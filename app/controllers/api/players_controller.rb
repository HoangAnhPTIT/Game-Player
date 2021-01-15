module Api
    class PlayersController < ApplicationController
        before_action :authorize_request
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
                render json: {player:player_show}
            else 
                render json: {player:player.errors}, status: :unprocessable_entity
            end
        end

        def show
            player = Player.find(params[:id])
            player_show = to_show(player)
            render json: {player:player_show}
        end

        def update
            player = Player.find(params[:id])
            
            if player.update(player_params)
                player_show = to_show(player)
                render json: {player:player_show}
            else 
                render json: {player:player.errors}, status: :unprocessable_entity
            end 
        end

        def destroy
            player = Player.find(params[:id])
            player.destroy
            player_show = to_show(player)
            render json: {player:player_show}
        end

        private
        def player_params
            params.permit(:username, :password, :fullname, :point, :wincount, :losecount, :status)
        end

        private
        def to_show(player)
            hash = Hash.new
            hash = {"id" => player.id, "name" => player.fullname, "point" => player.point, "wincount" => player.wincount, "losecount" => player.losecount}
            hash
        end

    end
    
end