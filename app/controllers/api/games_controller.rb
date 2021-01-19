module Api
  class GamesController < ApplicationController
    before_action :authorize_request
    before_action :admin_only, :except => :leaderboard
    def index; end

    def create
      players = params[:players]
      player_id_one = players['A']
      player_id_two = players['B']
      render json: { message: 'PLayer Invalid'} and return if player_id_one == player_id_two

      check_player_exist(player_id_one, player_id_two);  return if performed?

      check_player_ingame(player_id_one, player_id_two); return if performed?

      create_game(player_id_one, player_id_two); return if performed?

    end

    def check_player_exist(player_id_one, player_id_two)
      player_one = Player.find_by(id: player_id_one, status: true)
      player_two = Player.find_by(id: player_id_two, status: true)

      render json: { message: "Player's id 1 invalid Or Not login" } and return unless player_one.present?

      render json: { message: "Player's id 2 invalid Or Not login" } and return unless player_two.present?

    end

    def check_player_ingame(player_id_one, player_id_two)
      ingames = Game.where(status: true).pluck(:player1, :player2).flatten
      render json: { message: 'Player 1 In Game' }  and return if ingames.include?(player_id_one)
      render json: { message: 'Player 2 In Game' }  and return if ingames.include?(player_id_two)
    end

    def create_game(player_id_one, player_id_two)
      game = Game.create(player1: player_id_one, player2: player_id_two, winner: 0, status: 1)
      if game.save
        log = Log.create(point1: 0, point2: 0, gameid: game.id, status: true)
        log.save
        game_res = to_show_log(player_id_one, player_id_two, log.id, 0)
        render json: { game: game_res }
      else
        render json: { players: players.errors }
      end
    end

    def score
      player_id = params[:player_id]
      game_id = params[:gameid]
      game_model = Game.find_by(id: game_id)

      render json: { Message: "Log's id Invalid" } and return unless game_model.present?

      update_point_score(player_id, game_model)

    end

    def reset_point
      game_id = params[:gameid]
      player_id = params[:player_id]
      step = params[:step]
      action = params[:act]
      game_model = Game.find_by(id: game_id, status: true)
      render json: { massage: "Game's id invalid Or Game was end" } and return unless game_model.present?

      reset_player(player_id, game_model, game_id, step, action) and return if player_id.present?

      reset_no_player(step, game_id, action) and return unless player_id.present?

    end

    def reset_no_player(step, game_id, action)
      action_reset_no_player(step, game_id) and return if action == 'reset'
      action_revert_no_player(step) and return if action == 'revert'
    end

    def action_revert_no_player(step)
      tmps = Tmp.order('id DESC').limit(step).pluck(:logid, :point1, :point2)
      for tmp in tmps
        log = Log.find(tmp[0])
        log.update(point1: tmp[1], point2: tmp[2])
      end
    end

    def action_reset_no_player(step, game_id)
      logs = Log.where(gameid: game_id).order('id DESC').limit(step).pluck(:id, :point1, :point2, :gameid)
      last_log = logs.pop
      last_log_row = Log.find(last_log[0])
      for log in logs
        tmp = Tmp.find_by(logid: log[0])
        tmp.update(point1: log[1], point2: log[2]) if tmp.present?
        tmp = Tmp.create(logid: log[0], point1: log[1], point2: log[2], gameid: log[3]) and tmp.save unless tmp.present?
        log_db = Log.find(log[0])
        log_db.update(point1: last_log_row.point1, point2: last_log_row.point2)
      end
    end

    def reset_player(player_id, game_model, game_id, step, action)
      player_num = find_player(player_id, game_model)
      action_reset(game_id, step, player_num, player_id) if action == 'reset'

      action_revert(game_id, step, player_num, player_id) if action == 'revert'
      
      log_to_show = Log.find_by(gameid: game_id, status: true)
      render json: { Game: log_to_show }
    end

    def action_revert(game_id, step, player_num, player_id)
      tmps = Tmp.order('id DESC').limit(step).pluck(:logid, :point1, :point2)
      # binding.pry
      for tmp in tmps
        log = Log.find(tmp[0])
        update_point_object(log, player_num, tmp[1], tmp[2])
      end
    end

    def action_reset(game_id, step, player_num, player_id)
      logs = Log.where(gameid: game_id).order('id DESC').limit(step).pluck(:id, :point1, :point2, :gameid)
      last_log = logs.pop
      last_log_row = Log.find(last_log[0])
      # update_point_player(player_id, player_num, last_log)
      for log in logs
        tmp = Tmp.find_by(logid: log[0])
        update_point_object(tmp, player_num, log[1], log[2]) if tmp.present?
        tmp = Tmp.create(logid: log[0], point1: log[1], point2: log[2], gameid: log[3]) and tmp.save unless tmp.present?
        single_log = Log.find(log[0])
        update_point_object(single_log, player_num, last_log_row.point1, last_log_row.point2)
      end
    end

    def update_point_player(player_id, player_num, log)
      player_rs = player.find(player_id)
      player_rs.update(point: player_rs.point - log[1]) if player_num == 1
      player_rs.update(point: player_rs.point - log[2]) if player_num == 2
    end

    def update_point_object(object, player_num, point1, point2)
      if player_num == 1
        object.update(point1: point1)
      elsif player_num == 2
        object.update(point2: point2)
      end
    end

    def find_player(player_id, game)
      return 1 if game.player1 == player_id
      return 2 if game.player2 == player_id
    end

    def end_game
      game_id = params[:gameid]
      game_model = Game.find_by(id: game_id, status: true)
      render json: { message: "Game's id invalid Or Game was end" } and return unless game_model.present?

      log_model = Log.find_by(gameid: game_id, status: true)
      update_count(game_model.player1, game_model.player2, game_model) if log_model.point1 > log_model.point2
      update_count(game_model.player2, game_model.player1, game_model) if log_model.point1 < log_model.point2
      game_model.update(status: false, winner: 0) if log_model.point1 == log_model.point2
      log_model.update(status: false)
      render json: { message: 'End Game !!!' }
    end

    def show
      game_id = params[:id]
      game_model = Game.find_by(id: game_id)
      render json: { message: "Game's id invalid" } and return unless game_model.present?

      game_res = to_show_game(game_model.player1, game_model.player2, game_id, game_model.winner)
      render json: { game: game_res }
    end

    def leaderboard
      sql = 'SELECT * FROM players order by (wincount - losecount ) DESC'
      players = ActiveRecord::Base.connection.exec_query(sql).rows
      # binding.pry
      player_show = []
      players.each do |player|
        player_hash = {}
        player_hash.store('id', player[0])
        player_hash.store('name', player[1])
        player_hash.store('winscount', player[5])
        player_hash.store('losescount', player[6])
        player_show.push(player_hash)
      end
      render json: { players: player_show }
    end

    private

    def update_point_score(player_id, game_model)
      player = Player.find(player_id)
      player.update(point: player.point + 10)
      last_log = Log.find_by(status: true, gameid: game_model.id)
      log = Log.create(point1: last_log.point1 + 10, point2: last_log.point2, gameid: game_model.id, status: true) if player_id == game_model.player1
      log = Log.create(point1: last_log.point1, point2: last_log.point2 + 10, gameid: game_model.id, status: true) if player_id == game_model.player2
      render json: { Message: "Player's id Invalid" } and return unless log.present?

      log.save
      last_log.update(status: false)
      game_res = to_show_log(game_model.player1, game_model.player2, log.id, 0)
      render json: { game: game_res }
    end

    def destroy_update(player)
      player.update(point: player.point - 10)
      log_models = Log.order('created_at DESC').limit(2)
      log_model1 = log_models[0]
      log_model2 = log_models[1]
      log_model1.destroy
      log_model2.update(status: true)
    end

    def update_count(win_id, lose_id, game_model)
      game_model.update(status: false, winner: win_id)
      player1 = Player.find(win_id)
      player2 = Player.find(lose_id)
      player1.update(wincount: player1.wincount + 1)
      player2.update(losecount: player2.losecount + 1)
    end

    def to_show_log(id1, id2, id, winner)
      player_one = {}
      player_two = {}
      player_one.store('id', id1)
      player_two.store('id', id2)
      last_log = Log.order('created_at DESC').limit(1)[0]
      player_one.store('points', last_log.point1)
      player_two.store('points', last_log.point2)

      return_game_res(player_one, player_two, id, winner)
    end

    def to_show_game(id1, id2, id, winner)
      player_one = {}
      player_two = {}
      player_one.store('id', id1)
      player_two.store('id', id2)
      player_one.store('points', Player.find(id1).point)
      player_two.store('points', Player.find(id2).point)
      return_game_res(player_one, player_two, id, winner)
    end

    def return_game_res(player_one, player_two, id, winner)
      players = []
      players.push(player_one)
      players.push(player_two)
      game_res = {}
      game_res.store('id', id)
      game_res.store('players', players)
      game_res.store('winner', winner)

      game_res
    end

    def admin_only
      render json: {message: "Access denied"} and return if @current_user.roleid != 1
    end
  end
end
