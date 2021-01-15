module Api
    class GamesController < ApplicationController
        before_action :authorize_request

        def index
            
        end
        
        def create
            players = params[:players]
            player1 = players["A"]
            player2 = players["B"]
            if !Player.exists?(id: player1) || !Player.exists?(id: player2)
                render json: {message: "Player's id invalid"}
            else 
                game = Game.create(player1: player1, player2: player2, winner: 0, status: 1)
                if game.save
                    log = Log.create(point1: 0, point2: 0, gameid: game.id, status: true)
                    log.save
                    gameRes = to_show(player1, player2, log.id, 0, true)
                    render json: {game: gameRes}
                else 
                    render json: {players: players.errors}
                end
            end
        end

        def score
            playerId = params[:player_id]
            gameId = params[:gameid]
            gameModel = Game.find_by(id: gameId)
            if !gameModel.nil?
                update_point_score(playerId, gameModel)
            else
                render json: {Message: "Log's id Invalid"}
            end
        end

        def reset_point
            game_id = params[:gameid]
            player_id = params[:player_id]
            game_model = Game.find_by(id: game_id, status: true)
            if !game_model.nil?
                
                player = nil
                nice = 0
                if game_model.player1 == player_id
                    player = Player.find(player_id)
                    nice = 1
                elsif game_model.player2 == player_id
                    player = Player.find(player_id)
                    nice = 1
                end
                
                if nice == 1
                    if player.point > 0 
                        destroy_update(player)
                        render json: {massage: "Reset Success"}
                    else  
                        render json: {massage: "Can not reset due to point = 0"}
                    end
                else
                    render json: {massage: "Player's id invalid"}
                end
               
            else 
                render json: {massage: "Game's id invalid Or Game was end"}
            end

        end

        def end_game
            game_id = params[:gameid]
            game_model = Game.find_by(id: game_id, status: true)
            if !game_model.nil?
                log_model = Log.find_by(gameid: game_id, status: true)
                if log_model.point1 > log_model.point2
                    update_count(game_model.player1, game_model.player2, game_model)
                elsif log_model.point1 < log_model.point2
                    update_count(game_model.player2, game_model.player1, game_model)
                end
                log_model.update(status: false)
                render json: {message: "End Game !!!"}
            elsif
                render json: {message: "Game's id invalid Or Game was end"}
            end

        end

        def show
            game_id = params[:id]
            game_model = Game.find_by(id: game_id)
            if !game_model.nil?
                gameRes = to_show(game_model.player1, game_model.player2, game_id, game_model.winner, false)
                render json: {game: gameRes}
            elsif 
                render json: {message: "Game's id invalid"}
            end
        end

        def leaderboard
            players = Player.all
            player_show = Array.new
            for player in players
                player_hash = Hash.new
                player_hash.store("id", player.id)
                player_hash.store("name", player.fullname)
                player_hash.store("winscount", player.wincount)
                player_hash.store("losescount", player.losecount)
                player_show.push(player_hash)
            end
            render json: {players: player_show}
        end

        private
        def update_point_score(playerId, gameModel)
            player = Player.find(playerId)
            player.update(point: player.point+10)
            lastestLog = Log.find_by(status: true, gameid: gameModel.id)
            log = nil
            flag = 0
            if playerId == gameModel.player1
                log = Log.create(point1: lastestLog.point1 + 10, point2: lastestLog.point2, gameid: gameModel.id, status: true)
                flag = 1  
            elsif playerId == gameModel.player2
                log = Log.create(point1: lastestLog.point1, point2: lastestLog.point2 + 10, gameid: gameModel.id, status: true) 
                flag = 1
            end
            if flag
                log.save
                lastestLog.update(status: false)
                gameRes = to_show(gameModel.player1, gameModel.player2, log.id, 0, true)
                render json: {game: gameRes} 
            else
                render json: {Message: "Player's id Invalid"}
            end
            
        end

        private 
        def destroy_update(player)
            player.update(point: player.point - 10)
            log_models = Log.order('created_at DESC').limit(2)
            log_model1 = log_models[0]
            log_model2 = log_models[1]
            log_model1.destroy
            log_model2.update(status: true)
        end
        private 
        def update_count(win_id, lose_id, game_model)
            game_model.update(status: false, winner: win_id)
            player1 = Player.find(win_id)
            player2 = Player.find(lose_id)
            player1.update(wincount: player1.wincount + 1)
            player2.update(losecount: player2.losecount + 1)
        end

        private 
        def to_show(id1, id2, id, winner, for_player)
            player1 = Player.find(id1)
            player2 = Player.find(id2)
            player_1 = Hash.new
            player_1.store("id", id1)
            if !for_player
                lastestLog = Log.order('created_at DESC').limit(1)[0]
                player_1.store("points", lastestLog.point1)
            else 
                log_model = Log.find(id)
                player_1.store("points", log_model.point1)
            end
            player_2 = Hash.new
            player_2.store("id", id2)
            if !for_player
                lastestLog = Log.order('created_at DESC').limit(1)[0]
                player_2.store("points", lastestLog.point2)
            else 
                log_model = Log.find(id)
                player_2.store("points", log_model.point2)
            end
            players = Array.new
            players.push(player_1)
            players.push(player_2)
            gameRes = Hash.new
            gameRes.store("id", id)
            gameRes.store("players", players)
            gameRes.store("winner", winner)

            gameRes
        end
    end
end