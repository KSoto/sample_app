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
#

require 'spec_helper'

describe UsersController do
  render_views

describe "GET 'index'" do

    describe "for non-signed-in users" do
      before(:each) do
        #first need to create some pretend users:
        first = Factory(:user, :name => "Bill", :email => "another@example.org", :public => true)
        second = Factory(:user, :name => "Bob", :email => "another@example.com", :public => true)
        third  = Factory(:user, :name => "Ben", :email => "another@example.net", :public => false)
        fourth  = Factory(:user, :name => "Berry", :email => "another@example.co", :public => false)

        @users = [first, second, third, fourth]
      end
      
       it "should allow access" do
        get :index
        response.should be_success
       end
      
      it "should only show list of public profiles" do
         @users.each do |user|
           if(user.public) #if it's true
               get :index
               response.should have_selector("li", :content => user.name)
           elsif(!user.public) #if it's false
               get :index
               response.should_not have_selector("li", :content => user.name)
           end
          end
       end

      #this old test contradicts what we are doing now
        #it "should deny access" do
        #  get :index
        #  response.should redirect_to(signin_path)
        #  flash[:notice].sho.php~ /sign in/i
        #end
    end# end for non-signed in users

    describe "for signed-in users" do

      before(:each) do
        @user = test_sign_in(Factory(:user))
        first = Factory(:user, :name => "Bill", :email => "another@example.org", :public => true)
        second = Factory(:user, :name => "Bob", :email => "another@example.com", :public => true)
        third  = Factory(:user, :name => "Ben", :email => "another@example.net", :public => false)
        fourth  = Factory(:user, :name => "Berry", :email => "another@example.co", :public => false)

        
        @users = [@user, first, second, third, fourth]
        
        #for pagination
        30.times do
          @users << Factory(:user, :name => Factory.next(:name),
                                   :email => Factory.next(:email))
        end
      end
      
       it "should only show public and private profiles" do
         @users[0..4].each do |user|
           if(user.public) #if it's true
               get :index
               response.should have_selector("li", :content => user.name)
           elsif(!user.public) #if it's false
               get :index
               response.should have_selector("li", :content => user.name)
           end
          end
       end

      it "should be successful" do
        get :index
        response.should be_success
      end

      it "should have the right title" do
        get :index
        response.should have_selector("title", :content => "All users")
      end

      it "should have an element for each user" do
        get :index
        @users[0..4].each do |user|
          response.should have_selector("li", :content => user.name)
        end
      end
      
      it "should paginate users" do
        get :index
        response.should have_selector("div.pagination")
        response.should have_selector("span.disabled", :content => "Previous")
        response.should have_selector("a", :href => "/users?page=2",
                                           :content => "2")
        response.should have_selector("a", :href => "/users?page=2",
                                           :content => "Next")
      end
    end
  end
  
  describe "GET 'new'" do
    it "should be successful" do
      get 'new'
      response.should be_success
    end

    it "should have the right title" do
      get 'new'
      response.should have_selector("title", :content => "Sign up")
    end
  end
  
  #tests using FactoryGirl to simulate a user instance (7.3.1)
  describe "GET 'show'" do

    describe "for non-signed-in users" do
      before(:each) do
        #first need to create some pretend users:
        first = Factory(:user, :name => "Bill", :email => "another@example.org", :public => true)
        second = Factory(:user, :name => "Bob", :email => "another@example.com", :public => true)
        third  = Factory(:user, :name => "Ben", :email => "another@example.net", :public => false)
        fourth  = Factory(:user, :name => "Berry", :email => "another@example.co", :public => false)

        @users = [first, second, third, fourth]
      end
      
      it "should only show public profiles" do
         @users.each do |user|
           if(user.public) #if it's true
               get :show, :id => user.id
               response.should have_selector("h1", :content => user.name)
           elsif(!user.public) #if it's false
               get :show, :id => user.id
               response.should_not have_selector("h1", :content => user.name)
           end
          end
       end
      end#end for non-signed in users

    describe "for signed-in users" do
      before(:each) do
        @user = test_sign_in(Factory(:user))
        #first need to create some pretend users:
        first = Factory(:user, :name => "Bill", :email => "another@example.org", :public => true)
        second = Factory(:user, :name => "Bob", :email => "another@example.com", :public => true)
        third  = Factory(:user, :name => "Ben", :email => "another@example.net", :public => false)
        fourth  = Factory(:user, :name => "Berry", :email => "another@example.co", :public => false)

        @users = [@user, first, second, third, fourth]      
        #@user = Factory(:user)
      end
      
      it "should show public and private profiles" do
        @users[0..4].each do |user|
           if(user.public) #if it's public
               get :show, :id => user.id
               response.should have_selector("h1", :content => user.name)
           elsif(!user.public) #if it's private
               get :show, :id => user.id
               response.should have_selector("h1", :content => user.name)
           end
         end  
       end
       
    end#for signed-in users

    before(:each) do
      @user = Factory(:user)
    end
       
    it "should be successful" do
      get :show, :id => @user
      response.should be_success
    end

    it "should find the right user" do
      get :show, :id => @user
      assigns(:user).should == @user
    end
	
	  #Tests for the user show page (7.3.2)
	  it "should have the right title" do
      get :show, :id => @user
      response.should have_selector("title", :content => @user.name)
    end

    it "should include the user's name" do
      get :show, :id => @user
      response.should have_selector("h1", :content => @user.name)
    end

    it "should have a profile image" do
      get :show, :id => @user
      response.should have_selector("h1>img", :class => "gravatar")
    end
  end#end "GET 'show'"
  
 #test for the signup form (8.2.1)
describe "POST 'create'" do

    describe "failure" do
      
      before(:each) do
        @attr = { :name => "", :email => "", :password => "",
                  :password_confirmation => "" }
      end
      
      it "should have the right title" do
        post :create, :user => @attr
        response.should have_selector('title', :content => "Sign up")
      end

      it "should render the 'new' page" do
        post :create, :user => @attr
        response.should render_template('new')
      end

      it "should not create a user" do
        lambda do
          post :create, :user => @attr
        end.should_not change(User, :count)
      end
    end#end failure

    describe "success" do

      before(:each) do
        @attr = { :name => "New User", :email => "user@example.com",
                  :password => "foobar", :password_confirmation => "foobar" }
      end

      it "should create a user" do
        lambda do
          post :create, :user => @attr
        end.should change(User, :count).by(1)
      end
      
      it "should redirect to the user show page" do
        post :create, :user => @attr
        response.should redirect_to(user_path(assigns(:user)))
      end

      it "should have a welcome message" do
        post :create, :user => @attr
        flash[:success].should =~ /welcome to the sample app/i
      end
      
      it "should sign the user in" do
        post :create, :user => @attr
        controller.should be_signed_in
      end
    end#end success
  end#end POST 'create'
  
  describe "GET 'edit'" do

    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end

    it "should be successful" do
      get :edit, :id => @user
      response.should be_success
    end

    it "should have the right title" do
      get :edit, :id => @user
      response.should have_selector("title", :content => "Edit user")
    end

    it "should have a link to change the Gravatar" do
      get :edit, :id => @user
      gravatar_url = "http://gravatar.com/emails"
      response.should have_selector("a", :href => gravatar_url,
                                         :content => "change")
    end
    
    #Users can mark their profiles (/users/n/edit) public or private
    it "should have checkbox named 'public'" do
      get :edit, :id => @user
      response.should have_selector("input", :type => "checkbox", :name => "user[public]")
    end 
  end#end Get 'edit'
  
describe "authentication of edit/update pages" do

    before(:each) do
      @user = Factory(:user)
    end

    describe "for non-signed-in users" do

      it "should deny access to 'edit'" do
        get :edit, :id => @user
        response.should redirect_to(signin_path)
      end

      it "should deny access to 'update'" do
        put :update, :id => @user, :user => {}
        response.should redirect_to(signin_path)
      end
    end#end for non-signed-in users
    
   describe "for signed-in users" do

      before(:each) do
        wrong_user = Factory(:user, :email => "user@example.net")
        test_sign_in(wrong_user)
      end

      it "should require matching users for 'edit'" do
        get :edit, :id => @user
        response.should redirect_to(root_path)
      end

      it "should require matching users for 'update'" do
        put :update, :id => @user, :user => {}
        response.should redirect_to(root_path)
      end
    end#end for signed-in users
    
end#end authentication of edit/update pages
  
 describe "DELETE 'destroy'" do

    before(:each) do
      @user = Factory(:user)
    end

    describe "as a non-signed-in user" do
      it "should deny access" do
        delete :destroy, :id => @user
        response.should redirect_to(signin_path)
      end
    end

    describe "as a non-admin user" do
      it "should protect the page" do
        test_sign_in(@user)
        delete :destroy, :id => @user
        response.should redirect_to(root_path)
      end
    end

    describe "as an admin user" do

      before(:each) do
        admin = Factory(:user, :email => "admin@example.com", :admin => true)
        test_sign_in(admin)
      end

      it "should destroy the user" do
        lambda do
          delete :destroy, :id => @user
        end.should change(User, :count).by(-1)
      end

      it "should redirect to the users page" do
        delete :destroy, :id => @user
        response.should redirect_to(users_path)
      end
    end #end describe as an admin
  end #end describe delete destroy

end#end describe UsersController