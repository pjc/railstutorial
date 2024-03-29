require 'spec_helper'

describe "Authentication" do

  subject { page }	

  describe "signin" do
    before { visit signin_path }

    it { should have_selector('h1', 	text:'Sign in') }
    it { should have_selector('title', 	text:'Sign in') }

    describe "with invalid information" do
    	before { click_button "Sign in" }

    	it { should have_selector('div.alert.alert-error', text: 'Invalid') }
    	it { should have_selector('title', text: 'Sign in') }

      # Exercise 3 chapter 9
      it { should_not have_link('Profile') }
      it { should_not have_link('Settings') }

      # We render and not redirect_to so we need to use flash.now and not flash
      describe "after visiting another page" do
          before { click_link "Home" }

          it { should_not have_error_message('Invalid') }
      end
    end

    describe "with valid information" do
    	let(:user) { FactoryGirl.create(:user) }
    	before { sign_in(user) }

    	it { should have_selector('h1', 		text: user.name) }

      it { should have_link('Users',      href: users_path) }
    	it { should have_link('Profile', 		href: user_path(user)) }
      it { should have_link('Settings',   href: edit_user_path(user)) }
    	it { should have_link('Sign out',		href: signout_path) }

    	it { should_not have_link('Sign in',    href: signin_path) }

      describe "followed by signout" do
        before { click_link "Sign out" }
        it { should have_link "Sign in" }
      end
    end
  end

  describe "authorization (before_filter's)" do

    describe "for non-signed-in users" do
      let(:user) { FactoryGirl.create(:user) }

      describe "in the Users controller" do

        describe "visiting the edit page" do
          before  { get edit_user_path(user) }
          it      { response.should redirect_to(signin_path) }
        end

        describe "submitting to the update action" do
          before  { put user_path(user) }
          specify { response.should redirect_to(signin_path) }
        end

        describe "visiting the index page" do
          before  { get users_path }
          specify { response.should redirect_to(signin_path) }
        end
      end

      describe "when attempting to visit a protected page" do
        before do
          visit edit_user_path(user)
          fill_in "Email",    with: user.email
          fill_in "Password", with: user.password
          click_button "Sign in"
        end

        describe "after signing in"
          it "should render the desired protected page" do
            page.should have_selector('title', text: 'Edit user')
          end

          describe "when signing in again" do
            before do
              delete signout_path
              sign_in user
            end

            it "should render the default (profile) page" do
              page.should have_selector('title', text: user.name)
            end
          end
        end
      end

    describe "as wrong user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:wrong_user) { FactoryGirl.create(:user, email: 'wrong@example.com') }
      before { sign_in user }

      describe "visiting Users#edit page" do
        before { get edit_user_path(wrong_user) }
        it { response.should redirect_to(root_path) }

        # before { visit edit_user_path(wrong_user) }
        # it { should_not have_selector('title', text: full_title('Edit user')) }
      end

      describe "submitting a PUT request to the Users#update action" do
        before { put user_path(wrong_user) }
        it { response.should redirect_to(root_path) }
      end
    end

    describe "as non-admin user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:non_admin) { FactoryGirl.create(:user) }

      before { sign_in non_admin }

      describe "submitting DELETE request to the Users#destroy action" do
        before { delete user_path(user) }
        specify { response.should redirect_to(root_path) }
      end
    end

    describe "as signed-in user" do
      let(:user) { FactoryGirl.create(:user) }
      before { sign_in user }

      describe "visiting Users#new action" do
        before { get new_user_path }
        it { response.should redirect_to root_path }
      end

      describe "visiting Users#create action" do
        before { post users_path }
        it { response.should redirect_to root_path }
      end
    end
  end

  describe "destroying admin as admin" do
    let(:admin_user) { FactoryGirl.create(:user) }
    before do 
      admin_user.toggle!(:admin)
      # We need to sign in as we need current_user to work
      sign_in admin_user
    end

    it "should not be possible" do
      expect { delete user_path(admin_user) }.not_to change(User, :count)
    end
  end
end
