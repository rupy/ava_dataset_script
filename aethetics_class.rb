require 'fileutils'

class ManageAva

	def initialize
		@avatxt = File.open("AVA_dataset/AVA.txt").readlines
	end

	def get_index_by_imageid(id)
		id = id.to_s unless id.is_a?(String)
		line = @avatxt.find{|line| line.split[1] == id }
		if line.nil?
			nil
		else
			line.split[0].to_i
		end
	end

	def copy_by_aesthetics
		aesthetics_path = "AVA_dataset/aesthetics_image_lists" 
		aesthetics_output_dir = "aesthetics_class"

		Dir.foreach( aesthetics_path ) do |file|
			aesthetics_output_path = "#{aesthetics_output_dir}/#{file.split(".")[0]}"
			FileUtils.mkdir_p(aesthetics_output_path) unless FileTest.exist?(aesthetics_output_path)
		end

		Dir.foreach( aesthetics_path ) do |file|
			next if file =~ /^\./
			puts file
			File.open("#{aesthetics_path}/#{file}") do |f|
				f.each do |line|
					line.chomp!
					index = get_index_by_imageid(line)
					if index.nil?
						puts "#{line} is not found in AVA.txt"
						next
					end
					dir_num = (index -1) / 10000 + 1
					from_path = "image_max100k/#{sprintf("%03d", dir_num)}/#{index.to_s}.jpg"
					print "#{from_path} => "
					unless FileTest.exist?(from_path)
						puts "x"
						next
					end
					puts file.split(".")[0]
					to_path = "#{aesthetics_output_dir}/#{file.split(".")[0]}"
					FileUtils.cp(from_path, to_path)
				end
			end
		end

	end
end

ava = ManageAva.new
ava.copy_by_aesthetics
