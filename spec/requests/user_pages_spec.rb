require 'spec_helper'

describe "User Pages" do

  subject { page }

  describe "signup page" do

  	before { visit signup_path }

    it { should have_selector('h1', 	text: 'Sign up') }
    it { should have_selector('title', 	text: full_title('Sign up')) }
  end

  describe "profile page" do

  	let(:user) { FactoryGirl.create(:user) }
  	before { visit user_path(user) }

  	it { should have_selector('h1', 	text: user.name) }
  	it { should have_selector('title',	text: user.name) }
  end

  describe "signup" do

  	before { visit signup_path }

  	let(:submit) { "Create my account" }

  	describe "with invalid information" do
  		it "should not create a user" do
	  		# initial_count = User.count
	  		# click_button(submit)
	  		# after_count = User.count
	  		# initial_count.should == after_count
	  		expect { click_button submit }.not_to change(User, :count)
  		end

      describe "after submission" do

        before { click_button submit }

        it "should have all the right error messages" do
          should have_selector('div', text: "The form contains 6 errors.")
          # should have_content 'The form contains 6 errors.'

          should have_selector('li',  text: "Password can't be blank")
          should have_selector('li',  text: "Name can't be blank")
          should have_selector('li',  text: "Email can't be blank")
          should have_selector('li',  text: "Email is invalid")
          should have_selector('li',  text: "Password is too short")
          should have_selector('li',  text: "Password confirmation can't be blank")
        end

        it "should render sign up page again" do 
          should have_selector 'h1',    text: 'Sign up'
          should have_selector 'title', text: 'Sign up'
        end

      end
  	end

  	describe "with valid information" do
  		before do
  			fill_in "Name"				, with: "Theodore Dalrymple"
  			fill_in "Email"				, with: "test@example.com"
  			fill_in "Password"		,	with: "testpass"
  			fill_in "Confirmation",	with: "testpass"
  		end

  		it "should create a user" do
  			expect { click_button submit}.to change(User, :count).by(1)
  		end

      describe "after saving the user" do

        before { click_button submit }
        # This is the email info we just submitted in before do block
        let(:user) { User.find_by_email('test@example.com') }

        it "should redirect to profile page" do
          should have_selector('title', text: user.name)
        end

        it "should show flash success message" do
          should have_selector('div.alert.alert-success', text: "Welcome")
        end

        it "should have logged in" do
          should have_link('Sign out', href: signout_path)
        end
      end
  	end
  end

  describe "edit" do

    let(:user) { FactoryGirl.create(:user) }
    before { visit edit_user_path(user) }

    describe "page" do
      it { should have_selector('h1',     text: 'Update your profile') }
      it { should have_selector('title',  text: 'Edit user' ) }
      it { should have_link('change', href: 'http://gravatar.com/emails') }
    end

    describe "with invalid information" do
      before { click_button "Save changes" }

      it { should have_content('error') }
    end

    describe "with valid information" do
      let(:new_name)  { "Hans-Herman" }
      let(:new_email) { "hoppe@mises.com" }
      before do
        fill_in "Name",             with: new_name
        fill_in "Email",            with: new_email
        fill_in "Password",         with: user.password
        fill_in "Confirm Password", with: user.password_confirmation
        click_button "Save changes"
      end

      it { should have_selector('title'), text: new_name }
      it { should have_selector('div.alert.alert-success') }
      it { should have_link('Sign out',   href: signout_path) }
      specify { user.reload.name.should   == new_name }
      specify { user.reload.email.should  == new_email }
    end
  end
end
