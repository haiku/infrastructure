#!/bin/env ruby

require 'pathname'

# Minimum images
@MIN = 100

# Thresholds
# Young - Keep all builds
@YOUNG_THRESH = 500
# Then, only keep odd hrev numbers

if ARGV.count != 1
  puts "Usage: nightly-reaper.rb <ARCH_PATH>"
  exit 1
end

@target = Pathname.new(ARGV.first)

stage0 = []
Dir.foreach(@target) do |item|
	next if File.directory?(item)
	#next if item == '.' or item == '..'
	next if not item.end_with?(".zip")
	fields = item.split('-')
	if not fields[2].start_with?("hrev")
		puts "Warning: Skipping #{item} due to invalid name!"
	end
	hrev = fields[2].tr("hrev", "")
	full_file = @target.join(item).to_s
	stage0.push({rev: hrev.to_i, name: full_file})
end
stage0.sort! {|a,b| b[:rev] <=> a[:rev]}

if stage0.count < @MIN
	puts "Under #{@MIN} builds! Bailing..."
	exit 0
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

to_remove.each do |filename|
	begin
		puts "Removing #{filename[:name]}..."
		File.delete(filename[:name])
		# Also cleanup the sha256 and sig's no longer needed
		if File.file?("#{filename[:name]}.sha256")
			puts "Removing #{filename[:name]}.sha256..."
			File.delete("#{filename[:name]}.sha256")
		end
		if File.file?("#{filename[:name]}.sig")
			puts "Removing #{filename[:name]}.sig..."
			File.delete("#{filename[:name]}.sig")
		end
	rescue
		puts "ERROR REMOVING #{filename[:name]}!"
	end
end
