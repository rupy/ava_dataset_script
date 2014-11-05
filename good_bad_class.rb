require 'fileutils'

good_bad_dir = "good_bad"
good_dir = "good"
bad_dir = "bad"
good_path = good_bad_dir + "/" + good_dir
bad_path = good_bad_dir + "/" + bad_dir

FileUtils.mkdir_p(good_path) unless FileTest.exist?(good_path)
FileUtils.mkdir_p(bad_path) unless FileTest.exist?(bad_path)

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
		# puts good_votes_num
		# puts bad_votes_num
		dir_num = (index -1) / 10000 + 1
		from_path = "image_max100k/#{sprintf("%03d", dir_num)}/#{index.to_s}.jpg"
		to_path = ""
		puts from_path
		unless FileTest.exist?(from_path)
			next
		end
		if good_votes_num > bad_votes_num
			puts "good"
			to_path = good_path
		else
			puts "bad"
			to_path = bad_path
		end
		FileUtils.cp(from_path, to_path)
	end
end

