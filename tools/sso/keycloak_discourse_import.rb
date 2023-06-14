#!/bin/env ruby

require 'keycloak-admin'
require 'csv'
require 'pp'

if ARGV.count != 1 || !ENV["ADMIN_PASSWORD"] || !ENV["ADMIN_USERNAME"]
	puts "Usage: ADMIN_USERNAME=cooladmin ADMIN_PASSWORD=password1 ruby keycloak_import.rb <discourse csv>"
	exit(1)
end

KeycloakAdmin.configure do |config|
	config.use_service_account = false
	config.server_url		  = "https://sso.haiku-os.org"
	config.server_domain	   = "auth.haiku-os.org"
	config.client_id		   = "admin-cli"
	config.client_realm_name   = "master"
	config.use_service_account = false
	config.username			= ENV["ADMIN_USERNAME"]
	config.password			= ENV["ADMIN_PASSWORD"]
	config.logger			  = Logger.new(STDOUT)
	config.rest_client_options = { verify_ssl: OpenSSL::SSL::VERIFY_NONE }
end

users = CSV.read(ARGV.first, :headers => true)

users.each do |user|
	firstname = user[1].split(' ')[0]
	lastname = user[1].split(' ')[1]

	update_name = Hash.new
	update_name.merge!({firstName: firstname}) if firstname && firstname.length > 0
	update_name.merge!({lastName: lastname}) if lastname && lastname.length > 0

	username = user[2]
	email = user[3]
	password = (0...128).map { ('a'..'z').to_a[rand(26)] }.join
	email_verified = true

	# First, search for users with matching emails...
	existing_users = KeycloakAdmin.realm("haiku").users.search({email: email})
	if existing_users.count == 1
		puts "OK: user with email #{email} already exists in keycloak! Skipping..."
		next
	elsif existing_users.count > 1
		puts "ERROR: email #{email} exists in keycloak multiple times!"
		next
	end

	# Next, search for users with matching usernames... These users already exist
	# in keycloak with a different email.  This linkage is pretty loose :-\ luckily
	# if a user existed within gerrit a few weeks ago, it "overrides" discourse users
	existing_users = KeycloakAdmin.realm("haiku").users.search({username: username})
	if existing_users.count == 1
	   puts "WARNING: user with username #{username} already exists in keycloak! Skipping..."
	   next
	elsif existing_users.count > 1
	   puts "ERROR: username #{username} exists multiple times? :-/"
	   next
	end

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
