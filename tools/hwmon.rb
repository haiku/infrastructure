#!/usr/bin/ruby

require 'open3'
require 'mail'

@volumes = ["/", "/var/lib/docker"]

def raise_alert(subject_str, message_str)
	mail = Mail.new do
		from    'root@maui.haiku-os.org'
		to      'haiku-sysadmin@freelists.org'
		subject subject_str
		body    message_str
	end
	mail.deliver!
end

def check_btrfs()
	@volumes.each do |volume|
		stdout_str, error_str, status = Open3.capture3('btrfs', 'device', 'stats', '-c', volume)
		if status.success?
			subject = "[WARN] #{volume} @ maui is not consistent!"
			raise_alert(subject, stdout_str)
		end
	end
end

check_btrfs()
