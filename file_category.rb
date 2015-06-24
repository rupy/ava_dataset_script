require 'fileutils'

home_dir = ARGV[0]

category_num = 0
Dir.foreach( home_dir ) do |file|
	target_dir = "#{home_dir}/#{file}"
	next if file =~ /^\./
	next unless File.directory?(target_dir)
	# puts "+#{target_dir}"

	Dir.foreach( target_dir ) do |file2|
		target_file = "#{home_dir}/#{file2}"
		next if file2 =~ /^\./
		next if File.directory?(target_file)

		full_path = File::expand_path(target_file)

		puts "#{full_path} #{category_num}"

	end
	category_num += 1
end