module Api
    class UsersController < ApplicationController
        before_action :authorize_request
        before_action :admin_only, :except => :leaderboard
        def create 
            user = User.new(user_param)
            if user.save
                render json: {user: user}
            else
                render json: {error: user.errors},status: :unprocessable_entity

            end
        end

        def user_param
            params.permit(:username, :password, :fullname, :roleid)
        end

        def admin_only
            render json: {message: 'Access denied'} and return if @current_user.roleid != 1
        end
    end
end
