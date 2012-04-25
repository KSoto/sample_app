# == Schema Information
#
# Table name: users
#
#  id                 :integer         not null, primary key
#  name               :string(255)
#  email              :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  encrypted_password :string(255)
#  salt               :string(255)
#  admin              :boolean         default(FALSE)
#  public             :boolean         default(TRUE)
#

class UsersController < ApplicationController
  before_filter :authenticate, :only => [:edit, :update, :destroy] #index removed
  #only you can edit your profile info
  before_filter :correct_user, :only => [:edit, :update]
  before_filter :admin_user,   :only => :destroy
  
  #/users
  def index
    @title = "All users"
    if signed_in?
      @get_Users = User.all #get public and private profiles
    else
      @get_Users = User.find_all_by_public(true) #just get public profiles
    end
    @users = @get_Users.paginate(:page => params[:page])
  end
  
  #/users/1
  def show
    if signed_in? 
      #a signed in user can view any profile - public or private
      @user = User.find(params[:id])
      @title = @user.name
    else
      #if they are not signed in
      if(User.find(params[:id]).public) 
        #if the user's profile is public, then it's safe to display.
        @user = User.find(params[:id])
        @title = @user.name
      else
        #else, the user's profile is private! Deny access.
        deny_access
      end
    end  
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
  
  #/users/102/edit
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

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User destroyed."
    redirect_to users_path
  end
  
  private

    def authenticate
      deny_access unless signed_in?
    end
    
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end
    
    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end
end