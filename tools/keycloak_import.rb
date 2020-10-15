require 'keycloak-admin'
require 'csv'
require 'pp'

if ARGV.count != 1 || !ENV["ADMIN_PASSWORD"]
	puts "Usage: ADMIN_PASSWORD=password1 ruby keycloak_import.rb <discourse csv>"
	exit(1)
end

KeycloakAdmin.configure do |config|
  config.use_service_account = false
  config.server_url          = "https://auth.haiku-os.org/auth"
  config.server_domain       = "auth.haiku-os.org"
  config.client_id           = "admin-cli"
  config.client_realm_name   = "master"
  config.use_service_account = false
  config.username            = "admin"
  config.password            = ENV["ADMIN_PASSWORD"]
  config.logger              = Logger.new(STDOUT)
  config.rest_client_options = { verify_ssl: OpenSSL::SSL::VERIFY_NONE }
end

users = CSV.read(ARGV.first, :headers => true)

# XXX FIRST 3 USERS TO NOT SPAM EVERYONE WHILE IN DEV
users.first(3).each do |user|
	firstname = user[1].split(' ')[0]
	lastname = user[1].split(' ')[1]

	update_name = Hash.new
	update_name.merge!({firstName: firstname}) if firstname && firstname.length > 0
	update_name.merge!({lastName: lastname}) if lastname && lastname.length > 0

	username = user[2]
	email = user[3]
	password = (0...128).map { ('a'..'z').to_a[rand(26)] }.join
	email_verified = false
	begin
		KeycloakAdmin.realm("master").users.create!(username, email, password, email_verified, "en")
	rescue RuntimeError => error
		puts "FAIL - Unable to add #{username} - #{error}"
		next
	end
	puts "SUCCESS - Added #{username} - #{email}..."

	newuser = KeycloakAdmin.realm("master").users.search(email).first
	KeycloakAdmin.realm("master").users.update(newuser.id, update_name)
end
