module SessionsHelper

	def sign_in user
		# permanent means 20.years.from_now so this is the long form
		# cookies[:remember_token] = {	value: user.remember_token,
		#																expires: 20.years.from_now }
		cookies.permanent[:remember_token] = user.remember_token

		# we want to create current_user that is accessible in views and controllers
		# need to use self otherwise it would just be a local variable in this method
		self.current_user = user
	end

	def current_user=(user)
		@current_user = user
	end

	def current_user
		# If @current_user is not defined (i.e. we just signed in with sign_in user), 
		# than look it up via remember token
		@current_user ||= User.find_by_remember_token(cookies[:remember_token])
		# Also note that second time current_user is called this avoids new database lookup
	end

	def current_user? user
		user == current_user
	end

	def signed_in?
		!current_user.nil?
	end

	def sign_out
		self.current_user = nil
		cookies.delete(:remember_token)
	end

	# friendly forwarding
	def redirect_back_or default
		redirect_to session[:return_to] || default
		session.delete(:return_to)
	end

	def store_location
		session[:return_to] = request.url
	end
end
