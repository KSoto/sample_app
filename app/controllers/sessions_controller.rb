class SessionsController < ApplicationController

  def new
    @title = "Sign in"
  end

  def create
 user = User.authenticate(params[:session][:email],
                          params[:session][:password])
    if user.nil?
      flash.now[:error] = "Invalid email/password combination."
      @title = "Sign in"
      render 'new'
    else
      #sign in the user, depending on if they want to be remembered or not
      if ((params[:remember_me])=="1")
          flash[:success] = "You chose to be remembered, I will remember you"
          sign_in_permanent user
      else
          flash[:success] = "You chose NOT to be remembered, I NOT will remember you"
          sign_in_temporary user
      end
      redirect_to user
    end
  end

  def destroy
	    sign_out
    	redirect_to root_path
  end
end