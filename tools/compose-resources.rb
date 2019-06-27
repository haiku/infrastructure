#!/bin/ruby
#
# Copyright, 2019 Haiku, Inc. All rights reserved.
# Released under the terms of the MIT license.
#
# Authors:
#   Alexander von Gluck IV <kallisti5@unixzen.com>
#
# Description: Calculate the resource utilization of
# a series of docker-compose 3.0+ deployments

require 'yaml'

@metric_types = ['cpus']
@resource_types = ['limits', 'reservations']
totals = Hash.new
totals['services'] = 0

@metric_types.each do |metric|
  totals[metric] = Hash.new
  @resource_types.each do |type|
    totals[metric][type] = 0.0
  end
end

Dir.glob('*.yaml') do |compose_file|
  thegoods = YAML.load_file(compose_file)
  if thegoods['version'].to_f < 3.0
    puts "Skipping #{compose_file}, spec < 3.0!"
    next
  end
  thegoods['services'].each do |name,details|
    if !details.has_key?('deploy') || !details['deploy'].has_key?('resources')
      next
    end
    totals['services'] += 1
    @metric_types.each do |metric|
      @resource_types.each do |type|
        resources = details['deploy']['resources']
        if resources.has_key?(type)
          if resources[type].has_key?(metric)
            totals[metric][type] += resources[type][metric].to_f
          end
        end
      end
    end
  end
end

puts "#{totals['services']} services analyzed."
@metric_types.each do |metric|
  @resource_types.each do |type|
    puts "Total #{metric} #{type}: #{totals[metric][type]}"
  end
end
