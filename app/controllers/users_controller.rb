class UsersController < ApplicationController
  before_filter :authenticate, :only => [:edit, :update]
  #only you can edit your profile info
  before_filter :correct_user, :only => [:edit, :update]
  
  def show
    @user = User.find(params[:id])
	  @title = @user.name
  end

  def new
	@user = User.new
    @title = "Sign up"
  end
    
  def create
	#create a new user with the data received from form except for the "remember_me" param
    @user = User.new(params[:user])
	#once @user is defined properly, calling @user.save is all that�s needed to complete the registration
    if @user.save
      # Handle a successful save.
	  sign_in @user
	  flash[:success] = "Welcome to the Sample App!"
	  redirect_to @user
	  #could have also said redirect_to user_path(@user)
    else
	#re-render the signup page if invalid signup data is received.
      @title = "Sign up"
      render 'new'
    end
  end 
  
  def edit
    #before filer "correct_user" now defines @user so we don't need this line anymore
    #@user = User.find(params[:id])
    @title = "Edit user"
  end
  
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated."
      redirect_to @user
    else
      @title = "Edit user"
      render 'edit'
    end
  end

  
  private

    def authenticate
      deny_access unless signed_in?
    end
    
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end
end