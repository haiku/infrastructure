#!/bin/ruby

require 'yaml'
require 'pp'

if ARGV.count < 1
  puts "Usage: volume_planner.rb (path)"
  puts "  path == a directory containing docker swarm compose files"
  puts ""
  puts "This tool counts how many times volumes are shared between containers"
  exit 1
end

volumes = []
Dir.glob("#{ARGV.first}/*.yaml") do |item|
  next if item == '.' or item == '..'
  next if item == './docker-compose.yaml'
  puts "Processing #{item}..."
  compose = YAML.load_file(item)
  #volumes += compose['volumes'].keys
  compose['services'].each do |name, keys|
    next if keys['volumes'] == nil or keys['volumes'].count == 0
    keys['volumes'].each do |volume|
      next if volume[0,1] == "." or volume[0,1] == "/"
      volumes.push(volume.split(":").first)
    end
  end
end
shared_volumes = Hash.new
all_volumes = Hash[volumes.group_by {|x| x}.map {|k,v| [k,v.count]}]
all_volumes.each do |name, count|
  next if count == 1
  shared_volumes.merge!({name => count})
end

puts ""
puts "These volumes are shared by mulitple containers:"
shared_volumes.each do |volume,count|
  puts("  Volume: #{volume}, Attachments: #{count}")
end
