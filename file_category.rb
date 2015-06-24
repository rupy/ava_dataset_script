require 'fileutils'

home_dir = ".."

category_num = 0
Dir.foreach( home_dir ) do |file|
	target_dir = "#{home_dir}/#{file}"
	next if file =~ /^\./
	next unless File.directory?(target_dir)
	# puts "+#{target_dir}"

	Dir.foreach( target_dir ) do |file2|
		next if file2 =~ /^\./
		puts "#{target_dir}/#{file2} #{category_num}"

	end
	category_num += 1
end