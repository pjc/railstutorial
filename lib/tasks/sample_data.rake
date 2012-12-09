namespace :db do
	desc "Fill database with sample date"
	task populate: :environment do
		admin = User.create!(	name: "Peter-Jan Celis",
													email: "pj@celis.org",
													password: "abcdef",
													password_confirmation: "abcdef")
		# We toggle admin because admin is not mass assignable
		admin.toggle!(:admin) 
		puts "admin saved."
		99.times do |n|
			name 	= Faker::Name.name
			email = "example-#{n+1}@railstutorial.org"
			password = "password"
			User.create!(	name: name,
										email: email,
										password: password,
										password_confirmation: password)
			puts "user #{n+1} saved." 
		end
	end
end