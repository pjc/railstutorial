class UsersController < ApplicationController
  before_filter :signed_in_user,  only: [:index, :edit, :update]
  before_filter :correct_user,    only: [:edit, :update]
  before_filter :admin_user,      only: [:destroy]
  before_filter :not_signed_in,   only: [:new, :create]

  def index
    @users = User.paginate(page: params[:page])
  end

  def new
  	@user = User.new
  end

  def show
  	@user = User.find(params[:id])
  end

  def create
  	@user = User.new(params[:user])
  	if @user.save
      sign_in @user
      flash[:success] = "Welcome to the sample app!"
  		redirect_to user_path(@user.id)
  	else
  		render action: 'new'
  	end
  end

  def edit
    # We have put this line in before_filter :correct_user
    #
     @user = User.find(params[:id])
  end

  def update
    # We have put this line in before_filter :correct_user
    # @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      sign_in @user
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    user = User.find(params[:id])
    # This is extra auth check, because link to delete self
    # is not shown to the admin in the first place
    if !user.admin?
      user.destroy
      flash[:success] = "User destroyed successfully."
    else
      flash[:error] = "You can not delete yourself as admin." 
    end
    redirect_to users_url
  end

  private

  def signed_in_user
    unless signed_in?
      store_location
      redirect_to signin_url, notice: "Please sign in." 
    end
  end

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_path) unless current_user? @user
  end

  def admin_user
    redirect_to root_path unless current_user.admin? 
  end

  def not_signed_in
    redirect_to root_path if signed_in?
  end
end
