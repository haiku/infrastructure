#!/bin/env ruby

require 's3'
require 'pathname'

# Minimum images
@MIN = 100

# Thresholds
# Young - Keep all builds
@YOUNG_THRESH = 200
# Then, only keep odd hrev numbers

if ARGV.count != 2
  puts "Usage: nightly-reaper-s3.rb <BUCKET> <ARCH>"
  exit 1
end

@bucket = ARGV.first
@arch = ARGV.last

S3.host = ENV['S3_HOST']
service = S3::Service.new(:access_key_id => ENV['S3_ACCESS_KEY_ID'], :secret_access_key => ENV['S3_SECRET_ACCESS_KEY'])
if !service
  puts "Unable to connect to s3!"
end
bucket = service.bucket(@bucket)
if !bucket
  puts "Unable to access buckets!"
end
objects = bucket.objects
#objects.each do |object|
#  puts object.key
#end

stage0 = []
objects.each do |object|
	next if not object.key.start_with?("#{@arch}/")
	next if not object.key.end_with?(".zip")
	filename = File.basename(object.key)
	fields = filename.split('-')
	if not fields[2].start_with?("hrev")
		puts "Warning: Skipping #{item} due to invalid name!"
	end
	#hrev123_1 == hrev1231 which throws off "latest" build number
	hrev_raw = fields[2].split('_')
	hrev = hrev_raw.first.tr("hrev", "")
	stage0.push({rev: hrev.to_i, name: object.key, object: object})
end
stage0.sort! {|a,b| b[:rev] <=> a[:rev]}

if stage0.count < @MIN
	puts "Under #{@MIN} builds! Bailing..."
	exit 0
end

stage0.each do |object|
  puts object
end

result = []
latest_rev = stage0.first[:rev]

puts latest_rev

# Keep the young builds
stage0.each do |item|
	if item[:rev] > (latest_rev - @YOUNG_THRESH)
		puts "Young: Keeping #{item[:rev]} gt #{latest_rev - @YOUNG_THRESH}"
		result.push(item)
	elsif item[:rev] <= (latest_rev - @YOUNG_THRESH)
		if item[:rev].odd?
			puts "Mature : Keeping odd #{item[:rev]} lt #{latest_rev - @YOUNG_THRESH}"
			result.push(item)
		end
	end
end

to_remove = stage0 - result

puts "Removing: #{to_remove.count}"
#puts to_remove
puts "Keeping: #{result.count}"
#puts result

to_remove.each do |item|
	begin
		puts "Removing #{item[:name]}..."
		item[:object].destroy

		# Also cleanup the sha256 and sig's no longer needed
		checksum = bucket.object("#{item[:name]}.sha256")
		if checksum
			puts "Removing #{item[:name]}.sha256..."
			checksum.destroy
		end
		sigfile = bucket.object("#{item[:name]}.sig")
		if sigfile
			puts "Removing #{item[:name]}.sig..."
			sigfile.destroy
		end
	rescue
		puts "ERROR REMOVING #{filename[:name]}!"
	end
end
