#!/bin/env ruby

# Manually injects keycloak identities into gerrit notedb
# 1. export users of a group from gerrit
# 2. add an oauth2 linkage to keycloak to their notedb
# 3. commit and push

require 'json'
require 'fileutils'
require 'digest'
require 'pp'

if ARGV.count != 1
	puts "Usage: external_injector.rb <gerrit users json>"
	exit(1)
end

# ARGV.first is ...
# Contributors:
# curl -s --header "Content-Type: application/json" --user "username:password" https://review.haiku-os.org/a/groups/groupid/members | grep -v ")]}'" > ~/gerrit-developers.json

# All active users:
# for i in $(curl -s --header "Content-Type: application/json" --user "username:password" https://review.haiku-os.org/a/accounts/?q=is:active | grep -v ")]}'" | jq | grep _account_id | cut -d':' -f2); do curl -s --header "Content-Type: application/json" --user "username:password" https://review.haiku-os.org/a/accounts/$i | grep -v ")]}'" >> ~/gerrit-users.json; done

data = File.read(ARGV.first)
users = JSON.parse(data)

# git clone review.haiku-os.org:./All-Users.git
# cd All-Users.git
# git pull origin refs/meta/external-ids
# git checkout FETCH_HEAD

users.each do |user|
  firstname = user["name"].split(' ').first
  lastname = user["name"].gsub("#{firstname} ","").lstrip

  username = user["username"]
  email = user["email"]

  external_id = "keycloak-oauth:#{username.downcase}"
  external_id_hash = Digest::SHA1.hexdigest(external_id)

  if email == nil or email.length <= 3
    puts "SKIP: #{username} (#{firstname} #{lastname}) missing email! Skipping..."
    next
  end

  refid = external_id_hash.insert(2, '/')
  refid_segment = refid.split('/')
  Dir.mkdir(refid_segment[0]) unless Dir.exist?(refid_segment[0])
  data =  "[externalId \"#{external_id}\"]\n"
  data += "       accountId = #{user["_account_id"]}\n"
  data += "       email = #{email}\n"
  puts "Adding #{user["username"]} as #{refid}..."
  File.write(refid, data)
end

# git add ...
# git commit -a -m "updating identities"
# git push origin HEAD:refs/meta/external-ids
