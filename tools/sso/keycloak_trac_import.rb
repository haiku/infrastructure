#!/bin/env ruby

require 'keycloak-admin'
require 'csv'
require 'pp'

if ARGV.count != 1 || !ENV["ADMIN_PASSWORD"] || !ENV["ADMIN_USERNAME"]
	puts "Usage: ADMIN_USERNAME=cooladmin ADMIN_PASSWORD=password1 ruby keycloak_import.rb <discourse csv>"
	exit(1)
end


def valid_email?(email)
  !!(email =~ /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\z/)
end

def valid_username?(str)
  !!(str =~ /\A[a-z0-9\.\_\-]+\z/)
end

KeycloakAdmin.configure do |config|
	config.use_service_account = false
	config.server_url		  = "https://sso.haiku-os.org"
	config.server_domain	   = "sso.haiku-os.org"
	config.client_id		   = "admin-cli"
	config.client_realm_name   = "master"
	config.use_service_account = false
	config.username			= ENV["ADMIN_USERNAME"]
	config.password			= ENV["ADMIN_PASSWORD"]
	config.logger			  = Logger.new(STDOUT)
	#config.rest_client_options = { verify_ssl: OpenSSL::SSL::VERIFY_NONE }
end

users = CSV.read(ARGV.first, :headers => true)

users.each do |user|
	if user["name"] == nil
		firstname = "Unknown"
		lastname = "Unknown"
	else
		firstname = user["name"].split(' ')[0]
		lastname = user["name"].split(' ')[1]
	end

	update_name = Hash.new
	update_name.merge!({firstName: firstname}) if firstname && firstname.length > 0
	update_name.merge!({lastName: lastname}) if lastname && lastname.length > 0

	username = user["username"].downcase
	if user["email"] == nil
		next
	end
	email = user["email"].downcase
	password = (0...128).map { ('a'..'z').to_a[rand(26)] }.join
	email_verified = false
	value = user["tickets"].to_i + user["comments"].to_i

	# XXX: COMMENT ME OUT TO CHECK EACH USER IN KEYBASE
	#next

	if !valid_username?(username)
		puts "ERROR: Username #{username} is gross..."
		next
	end

	if email != nil and email.length > 3
		if !valid_email?(email)
			puts "ERROR: Email #{email} is gross..."
			next
		end
	end

	existing_users = KeycloakAdmin.realm("haiku").users.search({username: username})
	if existing_users.count == 1
		verified = existing_users.first.email_verified
		if existing_users.first.email == email
			if verified
				puts "OK: #{value} user with username #{username} already exists in keycloak with the correct email!"
			else
				puts "WARN: #{value} user with username #{username} already exists in keycloak with the correct email (but unverified)!"
			end
			next
		end
		if verified
			puts "ERROR: #{value} user with username #{username} already exists in keycloak with an incorrect email! (#{email} vs #{existing_users.first.email}"
		else
			puts "ERROR: #{value} user with username #{username} already exists in keycloak with an incorrect (unverified) email! (#{email} vs #{existing_users.first.email}"
		end
		next
	end

	next 

	if email != nil and email.length > 3
		if !valid_email?(email)
			puts "ERROR: Email #{email} is gross..."
			next
		end
		# First, search for users with matching emails...
		existing_users = KeycloakAdmin.realm("haiku").users.search({email: email})
		if existing_users.count == 1
			puts "FIX: #{value} trac user #{username} with email #{email} already exists in keycloak as #{existing_users.first.username}! Skipping..."
			next
		elsif existing_users.count > 1
			puts "ERROR: #{value} user #{username} with email #{email} exists in keycloak multiple times!"
			next
		end
	else
		puts "ERROR: #{value} user #{username} missing email!"
		next
	end

	puts "OK: #{value} Want to add #{username} with email #{email}"

	# XXX: COMMENT ME OUT TO CREATE EACH USER
	next

	# Now.. we have users in discourse without a matching email or username in keycloak
	#  let's create them
	begin
		KeycloakAdmin.realm("haiku").users.create!(username, email, password, email_verified, "en")
	rescue RuntimeError => error
		puts "FAIL: Unable to add #{username} - #{error}"
		next
	end
	puts "SUCCESS: Added #{username} - #{email}..."

	# Now... we update the user with their name from discourse
	newuser = KeycloakAdmin.realm("haiku").users.search(email).first
	KeycloakAdmin.realm("haiku").users.update(newuser.id, update_name)
end
