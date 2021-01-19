module Api
  class AuthenticationController < ApplicationController
    before_action :authorize_request, except: :login

    # POST /auth/login
    def login
      @user = User.find_by(username: params[:username])
      if params[:password] == @user.password
        role = 'ADMIN' if @user.roleid == 1
        role = 'USER' if @user.roleid == 2
        token = JsonWebToken.encode(id: @user.id, aud: role)
        time = Time.now + 24.hours.to_i
        render json: { token: token, exp: time.strftime('%m-%d-%Y %H:%M'),
                       username: @user.username }, status: :ok
      else
        render json: { error: 'Username Or Password invalid' }, status: :unauthorized
      end
    end

    private

    def login_params
      params.permit(:username, :password)
    end
  end
end