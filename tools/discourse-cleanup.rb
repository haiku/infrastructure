#!/bin/env ruby

# A work in progress tool to find users who were created back in the drupal
# days and clean them up.

require 'discourse_api'
require 'pp'

client = DiscourseApi::Client.new("https://discuss.haiku-os.org")
client.api_key = "API_KEY"
client.api_username = "USER_NAME"

page_id = 0
processed = 0
users = client.list_users("active")

jerks = Array.new

while users.count() > 0
  users.each do |user|
    if user["post_count"] > 0 || user["posts_read_count"] > 0 || user["admin"] == true || user["time_read"] > 0
      next
    end
    jerks.push(user["username"])
  end
  processed += users.count()
  print("Users Processed: #{processed}, Jerks: #{jerks.count()}\n")
  page_id += 1
  users = client.list_users("active", { "page": page_id })
end

pp jerks

# TODO: More validation, then delete?
