module SessionsHelper

  
  def sign_in_temporary(user)
    cookies.permanent.signed[:remember_token] = [user.id, user.salt]
    self.current_user = user
    #just use sessions 
          #OR 
    #use cookies, but don't set "expired at" so that the cookie will automatically be deleted upon browser exit
  end
  
  def sign_in_permanent(user)
    cookies.permanent.signed[:remember_token] = [user.id, user.salt]
    self.current_user = user
    #use cookies
  end

#special syntax for defining an assignment
  def current_user=(user)
    @current_user = user
  end

def current_user
    @current_user ||= user_from_remember_token
  end

def signed_in?
    !current_user.nil?
  end

def sign_out
    cookies.delete(:remember_token)
    self.current_user = nil
  end

  private

    def user_from_remember_token
      User.authenticate_with_salt(*remember_token)
    end

    def remember_token
      cookies.signed[:remember_token] || [nil, nil]
    end

end