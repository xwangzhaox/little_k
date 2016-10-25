# entity.rb

require 'crawler/entity/base'

module Crawler
	module Entity

		extend Base

		class << self

			def ImportFile
				page_cates = db_get_page_category
				filepath = ASSETS_DIR + "/crawler/entity/manual_add/"
				if File.directory?(filepath)
					Dir.foreach(filepath) do |filename|
				        if filename != "." and filename != ".."
				        	data = YAML.load_file(filepath + filename)
				        	url = data.get_url
				        	result = page_cates.find{|row|url==row["url_base"]}
				        	if result.nil?
				        		#import
				        	end
				        end
			     	end
			    end
			end
		end
	end
end