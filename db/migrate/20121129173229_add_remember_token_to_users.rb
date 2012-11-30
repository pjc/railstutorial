class AddRememberTokenToUsers < ActiveRecord::Migration
  def change
    add_column 	:users, :remember_token, :string
    # We add index because we expect to retrieve users by remember_token
    add_index 	:users, :remember_token
  end
end
