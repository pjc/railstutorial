class AddIndexToUsersEmail < ActiveRecord::Migration
  def change
  	# We add index because we expect to retrieve users by email
  	# We make index unique to avoid double click signup
  	add_index :users, :email, unique: true
  end
end
