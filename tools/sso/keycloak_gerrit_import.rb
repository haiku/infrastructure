#!/bin/env ruby

require 'keycloak-admin'
require 'csv'
require 'pp'
require 'json'

if ARGV.count != 1 || !ENV["ADMIN_PASSWORD"]
	puts "Usage: ADMIN_PASSWORD=password1 ruby keycloak_import.rb <gerrit users json>"
	exit(1)
end

KeycloakAdmin.configure do |config|
	config.use_service_account = false
	config.server_url            = "https://sso.haiku-os.org"
	config.server_domain	     = "sso.haiku-os.org"
	config.client_id	         = "admin-cli"
	config.client_realm_name	 = "master"
	config.use_service_account = false
	config.username	          = "admin"
	config.password	          = ENV["ADMIN_PASSWORD"]
	config.logger	            = Logger.new(STDOUT)
	config.rest_client_options = { verify_ssl: OpenSSL::SSL::VERIFY_NONE }
end

# Developers:
# curl -s --header "Content-Type: application/json" --user "username:password" https://review.haiku-os.org/a/groups/groupid/members | grep -v ")]}'" > ~/gerrit-developers.json
#
# All active users:
# for i in $(curl -s --header "Content-Type: application/json" --user "username:password" https://review.haiku-os.org/a/accounts/?q=is:active | grep -v ")]}'" | jq | grep _account_id | cut -d':' -f2); do curl -s --header "Content-Type: application/json" --user "username:password" https://review.haiku-os.org/a/accounts/$i | grep -v ")]}'" >> ~/gerrit-users.json; done

data = File.read(ARGV.first)
users = JSON.parse(data)

#users = CSV.read(ARGV.first, :headers => true)
users.each do |user|
	firstname = user["name"].split(' ').first
	lastname = user["name"].gsub("#{firstname} ","").lstrip

	username = user["username"]
	email = user["email"]
	password = (0...128).map { ('a'..'z').to_a[rand(26)] }.join
	email_verified = true

    if email == nil or email.length <= 3
      puts "SKIP: #{username} (#{firstname} #{lastname}) missing email! Skipping..."
      next
    end

	puts "ADD: #{username}, #{email}, #{password}..."
	begin
		KeycloakAdmin.realm("haiku").users.create!(username, email, password, email_verified, "en")
	rescue RuntimeError => error
		puts "FAIL: Unable to add #{username} - #{error}"
		next
	end

	update_name = Hash.new
	update_name.merge!({firstName: firstname}) if firstname && firstname.length > 0
	update_name.merge!({lastName: lastname}) if lastname && lastname.length > 0

	begin
		user = KeycloakAdmin.realm("haiku").users.search(email).first
		KeycloakAdmin.realm("haiku").users.update(user.id, update_name)
	rescue RuntimeError => error
		puts "FAIL: Unable to update name of #{username} to #{user["name"]}: #{error}"
		next
	end
end
