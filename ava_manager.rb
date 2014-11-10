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

		@style_image_lists_dir = "AVA_dataset/style_image_lists"
		@style_output_dir = "style_class"
		@styletxt = File.open("#{@ava_dir}/#{@style_image_lists_dir}/styles.txt").readlines
		@style_info = parse_styletxt
		@style_label_info = set_style_label_info
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
		result = Hash.new
		@tagtxt.each do |line|
			row = line.split
			result[row[0].to_i] = row[1]
		end
		result
	end

	def parse_styletxt
		result = Hash.new
		@styletxt.each do |line|
			row = line.split
			result[row[0].to_i] = row[1]
		end
		result
	end

	def get_from_path(image_id)
		image_id = image_id.to_i if image_id.is_a?(String)
		dir_num = (image_id -1) / 10000 + 1
		from_path = "#{@ava_dir}/#{@image_source_dir}/#{sprintf("%03d", dir_num)}/#{image_id.to_s}.jpg"
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
					# if index.nil?
					# 	puts "#{line} is not found in AVA.txt"
					# 	next
					# end
					from_path = get_from_path(line)
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

		@ava_info.each_with_index do |line, i|
			print "#{i * 100 / @ava_info.length} % "
			from_path = get_from_path(line['image_id'])
			print "#{from_path} => "
			unless FileTest.exist?(from_path)
				puts "x"
				next
			end
			line['semantic_tags'].each do |tag_id|
				next if tag_id == 0
				print tagname = get_tagname_from_id(tag_id), " "
				to_path = "#{@ava_dir}/#{@semantic_tag_dir}/#{sprintf("%02d", tag_id)}_#{tagname}"
				FileUtils.cp(from_path, to_path)
			end
			# none of semantic tag
			print "@None" if line['semantic_tags'].all?{|tag_id|tag_id == 0}
			puts ""
			
		end
		puts "100 %"
	end

	def generate_dir_for_good_bad

		FileUtils.mkdir_p(@good_path) unless FileTest.exist?(@good_path)
		FileUtils.mkdir_p(@bad_path) unless FileTest.exist?(@bad_path)
	end

	def copy_by_good_bad

		generate_dir_for_good_bad

		@ava_info.each_with_index do |line, i|

			print "#{i * 100 / @ava_info.length} % "
			from_path = get_from_path(line['image_id'])
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
		puts "100 %"

	end

	def get_stylename(id)
		return "" if id == 0
		@style_info[id]
	end

	def set_style_label_info
		result = Hash.new 
		train_ids = File.open( "#{@ava_dir}/#{@style_image_lists_dir}/train.jpgl").readlines.map{|line|line.to_i}
		train_labs = File.open( "#{@ava_dir}/#{@style_image_lists_dir}/train.lab").readlines.map{|line|line.to_i}
		Hash[*train_ids.zip(train_labs).flatten]
	end

	def generate_dir_for_style
		
		for i in 1..@style_info.size do
			puts stylename = get_stylename(i)
			style_path = "#{@ava_dir}/#{@style_output_dir}/#{sprintf("%02d", i)}_#{stylename}"
			FileUtils.mkdir_p(style_path) unless FileTest.exist?(style_path)
		end
	end

	def copy_by_style
		generate_dir_for_style

		@style_label_info.each_with_index do |(image_id, label), i|
			print "#{i * 100 / @style_label_info.size} % "
			from_path = get_from_path(image_id)
			print "#{from_path} => "
			unless FileTest.exist?(from_path)
				puts "x"
				next
			end
			print style_name = get_stylename(label), " "
			to_path = "#{@ava_dir}/#{@style_output_dir}/#{sprintf("%02d", label)}_#{style_name}"
			FileUtils.cp(from_path, to_path)
			puts ""
		end
		puts "100 %"

	end
end

