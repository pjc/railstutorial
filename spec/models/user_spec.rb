# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe User do
	before do 
		@user = User.new(	name:'pj', email:'pj@celis.org',
											password:'foobar', password_confirmation:'foobar') 
	end

	subject { @user }

	# Sanity check
	it { should be_valid }

	# Check all attributes in model (plus password/password_digest for has_secure_password)
	it { should respond_to(:name) }
	it { should respond_to(:email) }
	it { should respond_to(:password_digest) }
	it { should respond_to(:password) }
	it { should respond_to(:password_confirmation) }
	it { should respond_to(:authenticate) } 
	it { should respond_to(:remember_token) }

	describe "when name is not present" do
		before { @user.name = "" }
		it { should_not be_valid }
	end

	describe "when email is not present" do
		before { @user.email = "" }
		it { should_not be_valid }
	end

	describe "when name is too long" do
		before { @user.name = 'a' * 51 }
		it { should_not be_valid }
	end

	describe "when email format is not valid" do
		addresses = %w[user@foo,com user_at_foo.org example.user@foo. 
					   foo@bar_baz.com foo@bar+baz.com]
		addresses.each do |invalid_address|
			before { @user.email = invalid_address }
			it { should_not be_valid }
		end
	end

	describe "when email format is valid" do
		addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp
					   a+b@baz.cn 1_____2@gmail.com]
		addresses.each do |valid_address|
			before { @user.email = valid_address }
			it { should be_valid }
		end
	end

	describe "when the email is not unique" do
		before do 
			copied_user = @user.dup
			copied_user.email = @user.email.upcase
			copied_user.save
		end
		it { should_not be_valid }
	end

	describe "when password is not present" do
		before { @user.password = @user.password_confirmation = " " }
		it { should_not be_valid }  
	end

	describe "when password doesn't match confirmation" do
		before { @user.password_confirmation = "mismatch" }
		it { should_not be_valid }
	end

	# Special freak case that can only happen via rails console, not via web
	describe "when password confirmation is nil" do
		before { @user.password_confirmation = nil }
		it { should_not be_valid }
	end

	describe "with a password that's too short" do
		before { @user.password = @user.password_confirmation = 'a'*5 }
		it { should_not be_valid } 
	end

	describe "with an email that's mixed case" do
		let(:mixed_case_email) { "aNyThinhMIXEd@gmaIL.COM" }

		it "should be saved as all lower case" do
			@user.email = mixed_case_email
			@user.save
			@user.reload.email.should == mixed_case_email.downcase
		end
	end

	describe "return value of authenticate method" do

		before { @user.save }
		let(:found_user) { User.find_by_email(@user.email) }

		describe "with valid password" do
			it { should == found_user.authenticate(@user.password) }
		end

		describe "with invalid password" do
			let(:user_for_invalid_password) { found_user.authenticate("invalid") }
			it { should_not == user_for_invalid_password }
			# it and specify are synonyms, use what 'reads' best
			specify { user_for_invalid_password.should be_false }
		end

	end 

	describe "remember token" do
		before { @user.save }
		# it { @user.remember_token.should_not be_blank }
		its(:remember_token) { should_not be_blank }
	end
end




