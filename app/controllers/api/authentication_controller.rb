module Api
  class AuthenticationController < ApplicationController
    skip_before_action :authenticate_request, only: [ :login ]

    def login
      @user = User.find_by(email: params[:email])

      if @user&.authenticate(params[:password])
        access_token = encoded_auth_token(@user)
        refresh_token = encoded_refresh_token(@user)

        render json: { email: @user.email, access_token: access_token, refresh_token: refresh_token }, status: :ok
        return
      end

      render json: { error: "Invalid credentials" }, status: :unauthorized
    end

    def refresh
      if @current_user && @current_user.refresh_token == AuthorizeApiRequest.http_auth_header(request.headers)
        access_token = encoded_auth_token(@current_user)
        render json: { access_token: access_token }, status: :ok
      end
    end

    def logout
      if @current_user
        @current_user.transaction { @current_user.update!(refresh_token: nil) }
        render json: { message: "Logged out successfully" }, status: :ok
      end
    end
  end
end
