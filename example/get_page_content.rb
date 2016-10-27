# get_page_content.rb
ASSETS_DIR = File.expand_path File.join(File.dirname(__FILE__), '../lib')
$LOAD_PATH.unshift(ASSETS_DIR)

require 'pry'
require 'crawler/page'

module Crawler
	class GetPageContent
		def work
			@ttd = %w(https://xueqiu.com/S/SZ000736 https://xueqiu.com/S/SH601595/GSJJ https://xueqiu.com/S/SH600977 https://xueqiu.com/S/SH601595 https://xueqiu.com/S/SH601595)

			page = Page.Page({:url => @ttd.first})
			if page.stru_record_exist?
				page.objectification
			else
				page.comparsion_page @ttd[2], false
				if page.diff_hash
					page.objectification 
				else
					puts "There has somthing wrong."
				end
			end
			page.attributes_item
			page.save
		end
	end
end
Crawler::GetPageContent.new.work