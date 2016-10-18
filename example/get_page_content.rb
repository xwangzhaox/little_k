# get_page_content.rb
ASSETS_DIR = File.expand_path File.join(File.dirname(__FILE__), '../lib')
$LOAD_PATH.unshift(ASSETS_DIR)

require 'pry'
require 'crawler/page'

module Crawler
	class GetPageContent
		def work
			@ttd = %w(https://xueqiu.com/S/SZ000736 https://xueqiu.com/S/SH601595/GSJJ https://xueqiu.com/S/SH600977 https://xueqiu.com/S/SH601595 https://xueqiu.com/S/SH601595)
			@page1 = Page.SimpleCode @ttd.first
			# puts @page1.scan_html_structrue
			a, b = @page1.comparsion_page @ttd[2], false
			tot = Page.ToObject({:diff => b[:diff], :url => @ttd.first})
			tot.first_child
		end
	end
end
Crawler::GetPageContent.new.work