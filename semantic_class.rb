require 'fileutils'

def get_tagname_from_id(id)
	result = nil
	return "" if id == 0
	File.open("AVA_dataset/tags.txt") do |f|
		result = f.grep(/^#{id}\b/).first
	end
	result.split[1]
end

semantic_tag_dir = "semantic_tag"
for i in 1..66 do
	puts tagname = get_tagname_from_id(i)
	semantic_tag_path = "#{semantic_tag_dir}/#{sprintf("%02d", i)}_#{tagname}"
	FileUtils.mkdir_p(semantic_tag_path) unless FileTest.exist?(semantic_tag_path)
end

File.open("AVA_dataset/AVA.txt") do |f|

	f.each do |line|

		row = line.split
		index = row[0].to_i
		image_id = row[1].to_i
		votes = row[2..11].map{|i|i.to_i}
		semantic_tags = row[12..13].map{|i|i.to_i}
		challenge_id = row[14].to_i
		bad_votes_num = votes[0...5].inject(0){|sum, n| sum + n}
		good_votes_num = votes[5...10].inject(0){|sum, n| sum + n}

		dir_num = (index -1) / 10000 + 1
		from_path = "image_max100k/#{sprintf("%03d", dir_num)}/#{index.to_s}.jpg"
		to_path = ""
		print "#{from_path} => "
		unless FileTest.exist?(from_path)
			puts "x"
			next
		end
		semantic_tags.each do |tag|
			next if tag == 0
			print tagname = get_tagname_from_id(tag), " "
			to_path = "#{semantic_tag_dir}/#{sprintf("%02d", tag)}_#{tagname}"
			FileUtils.cp(from_path, to_path)
		end
		puts ""
	end
end

