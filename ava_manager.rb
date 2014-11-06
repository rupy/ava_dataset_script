require 'fileutils'

class AvaManager

	def initialize
		@ava_dir = ".."
		@avatxt = File.open( "#{@ava_dir}/AVA_dataset/AVA.txt").readlines
		@ava_info = parse_avatxt

		@tagtxt = File.open("#{@ava_dir}/AVA_dataset/tags.txt").readlines
		@tag_info = parse_tagtxt

		@good_bad_dir = "good_bad"
		@good_path = "#{@ava_dir}/#{@good_bad_dir}/good_dir"
		@bad_path = "#{@ava_dir}/#{@good_bad_dir}/bad_dir"

		@aesthetics_path = "#{@ava_dir}/AVA_dataset/aesthetics_image_lists" 
		@aesthetics_output_dir = "aesthetics_class"
		@image_source_dir = "image_max100k"

		@semantic_tag_dir = "semantic_tag"
	end

	def parse_avatxt
		@avatxt.map do |line|
			row = line.split
			result = Hash.new
			result['index'] = row[0].to_i
			result['image_id'] = row[1].to_i
			result['votes'] = row[2..11].map{|i|i.to_i}
			result['semantic_tags'] = row[12..13].map{|i|i.to_i}
			result['challenge_id'] = row[14].to_i
			result['bad_votes_num'] = result['votes'][0...5].inject(0){|sum, n| sum + n}
			result['good_votes_num'] = result['votes'][5...10].inject(0){|sum, n| sum + n}
			result
		end
	end

	def parse_tagtxt
		result = Array.new
		@tagtxt.each do |line|
			row = line.split
			result[row[0].to_i] = row[1]
		end
		result
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

	def generate_dir_for_aesthetics
		Dir.foreach( @aesthetics_path ) do |file|
			aesthetics_output_path = "#{@ava_dir}/#{@aesthetics_output_dir}/#{file.split(".")[0]}"
			FileUtils.mkdir_p(aesthetics_output_path) unless FileTest.exist?(aesthetics_output_path)
		end
	end

	def copy_by_aesthetics
		generate_dir_for_aesthetics

		Dir.foreach( @aesthetics_path ) do |file|
			next if file =~ /^\./
			puts file
			File.open("#{@aesthetics_path}/#{file}") do |f|
				f.each do |line|
					line.chomp!
					index = get_index_by_imageid(line)
					if index.nil?
						puts "#{line} is not found in AVA.txt"
						next
					end
					dir_num = (index -1) / 10000 + 1
					from_path = "#{@ava_dir}/#{@image_source_dir}/#{sprintf("%03d", dir_num)}/#{index.to_s}.jpg"
					print "#{from_path} => "
					unless FileTest.exist?(from_path)
						puts "x"
						next
					end
					puts file.split(".")[0]
					to_path = "#{@ava_dir}/#{@aesthetics_output_dir}/#{file.split(".")[0]}"
					FileUtils.cp(from_path, to_path)
				end
			end
		end

	end

	def get_tagname_from_id(id)
		return "" if id == 0
		@tag_info[id]
	end

	def generate_dir_for_semantic
		for i in 1..66 do
			puts tagname = get_tagname_from_id(i)
			semantic_tag_path = "#{@ava_dir}/#{@semantic_tag_dir}/#{sprintf("%02d", i)}_#{tagname}"
			FileUtils.mkdir_p(semantic_tag_path) unless FileTest.exist?(semantic_tag_path)
		end
	end


	def copy_by_semantic
		generate_dir_for_semantic

		@ava_info.each do |line|
			dir_num = (line['index'] -1) / 10000 + 1
			from_path = "#{@ava_dir}/#{@image_source_dir}/#{sprintf("%03d", dir_num)}/#{line['index'].to_s}.jpg"
			to_path = ""
			print "#{from_path} => "
			unless FileTest.exist?(from_path)
				puts "x"
				next
			end
			line['semantic_tags'].each do |tag|
				next if tag == 0
				print tagname = get_tagname_from_id(tag), " "
				to_path = "#{@ava_dir}/#{@semantic_tag_dir}/#{sprintf("%02d", tag)}_#{tagname}"
				FileUtils.cp(from_path, to_path)
			end
			print "@None" if line['semantic_tags'].all?{|tag|tag == 0}
			puts ""
			
		end
	end

	def generate_dir_for_good_bad

		FileUtils.mkdir_p(@good_path) unless FileTest.exist?(@good_path)
		FileUtils.mkdir_p(@bad_path) unless FileTest.exist?(@bad_path)
	end

	def copy_by_good_bad

		generate_dir_for_good_bad

		@ava_info.each do |line|
			dir_num = (line['index'] -1) / 10000 + 1
			from_path = "#{@ava_dir}/#{@image_source_dir}/#{sprintf("%03d", dir_num)}/#{line['index'].to_s}.jpg"
			to_path = ""
			print "#{from_path} => "
			unless FileTest.exist?(from_path)
				puts "x"
				next
			end
			if line['good_votes_num'] > line['bad_votes_num']
				puts "good"
				to_path = @good_path
			else
				puts "bad"
				to_path = @bad_path
			end
			FileUtils.cp(from_path, to_path)

		end

	end
end

