# import_manual_data.rb

# get_page_content.rb
ASSETS_DIR = File.expand_path File.join(File.dirname(__FILE__), '../lib')
$LOAD_PATH.unshift(ASSETS_DIR)

require 'pry'
require 'crawler/entity'
require 'yaml'

module Crawler
	class ImportManualData
		def work
			Entity.ImportFile
		end
	end
end
Crawler::ImportManualData.new.work