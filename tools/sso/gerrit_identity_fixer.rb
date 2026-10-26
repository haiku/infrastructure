#!/bin/env ruby

require 'json'
require 'fileutils'
require 'digest'
require 'pp'

if ARGV.count != 3
	puts "Usage: external_injector.rb <account_id> <SSO email> <SSO username>"
	exit(1)
end

# git clone review.haiku-os.org:./All-Users.git
# cd All-Users.git
# git pull origin refs/meta/external-ids
# git checkout FETCH_HEAD

accountid = ARGV[0]
email = ARGV[1]
username = ARGV[2]

external_id = "keycloak-oauth:#{username.downcase}"
external_id_hash = Digest::SHA1.hexdigest(external_id)

refid = external_id_hash.insert(2, '/')
refid_segment = refid.split('/')
Dir.mkdir(refid_segment[0]) unless Dir.exist?(refid_segment[0])
data =  "[externalId \"#{external_id}\"]\n"
data += "       accountId = #{accountid}\n"
data += "       email = #{email}\n"
puts "Adding #{username} as #{refid}..."
File.write(refid, data)

# git add ...
# git commit -a -m "updating identities"
# git push origin HEAD:refs/meta/external-ids
