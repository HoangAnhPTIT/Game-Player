# include JsonWebToken
module Api
  

  class AuthenticationController < ApplicationController
    
      before_action :authorize_request, except: :login
    
      # POST /auth/login
      def login
        @user = Player.find_by(username: params[:username])
        if params[:password] == @user.password
          token = JsonWebToken.encode(id: @user.id)
          time = Time.now + 24.hours.to_i
          render json: { token: token, exp: time.strftime("%m-%d-%Y %H:%M"),
                        username: @user.username }, status: :ok
        else
          render json: { error: 'unauthorized' }, status: :unauthorized
        end
      end
    
      private
      def login_params
        params.permit(:username, :password)
      end
  end
end