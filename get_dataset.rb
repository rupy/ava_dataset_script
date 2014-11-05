require 'fileutils'
require 'open-uri'
require 'nokogiri'

def get_image_url(dataset_url)
  charset = nil
  html = open(dataset_url) do |f|
    charset = f.charset
    f.read
  end
  
  doc = Nokogiri::HTML.parse(html, nil, charset)
  
  puts doc.title
  doc.xpath('//td[@id="img_container"]//img').each do |node|
    
    img_url = node.attribute('src').value
    unless img_url == "/images/pix.gif"
      return img_url
    end
  end
end

def get_images(file_name)
  list_dir = "aesthetics_image_lists"
  file_path = "#{list_dir}/#{file_name}"
  image_dir = "dataset_image"
  dataset_url_base = "http://www.dpchallenge.com/image.php?IMAGE_ID="
  
  new_dir = file_name.split(".")[0]
  image_path = "#{image_dir}/#{new_dir}"
  unless FileTest.exists?(image_path)
    FileUtils.mkdir_p(image_path)
  end
  
  File::open(file_path) do |f|
    f.each do |line|
      image_id = line.chomp
      # `wget -P #{image_path} #{dataset_url_base}#{image_id}`
      output_path = "#{image_path}/#{image_id}.jpg"
      dataset_url = "#{dataset_url_base}#{image_id}"
      puts "getting #{image_id} and saving file to #{output_path}"
      image_url = get_image_url dataset_url
      
      open(output_path, 'wb') do |output|
        open(image_url) do |data|
          output.write(data.read)
        end
      end
    end
  end
end

list_dir = "aesthetics_image_lists"
Dir.foreach(list_dir) do |file_name| 
  next if file_name =~ /^\.{1,2}/
  puts "============================"
  puts "get image files listed in #{list_dir}/#{file_name}"
  get_images file_name
end
