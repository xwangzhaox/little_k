$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'pry'
require 'crawler/page'

module Crawler
	class Crawler

		def work
			@ttd = %w(https://xueqiu.com/S/SZ000736 https://xueqiu.com/S/SH601595/GSJJ https://xueqiu.com/S/SH600977 https://xueqiu.com/S/SH601595 https://xueqiu.com/S/SH601595)
			@page1 = Page.SimpleCode @ttd.first
			# puts @page1.scan_html_structrue
			@page1.comparsion_page @ttd.first
		end

		def testing
			# @ttd = %w(https://xueqiu.com/S/SZ000736 https://xueqiu.com/S/SH601595/GSJJ https://xueqiu.com/S/SH600977 https://xueqiu.com/S/SH601595 https://xueqiu.com/S/SH601595)
			# @page1 = Page.SimpleCode @ttd.first
			# puts @page1.scan_html_structrue
			Page::SimpleCode.get_last_report_file
		end
	end
end
Crawler::Crawler.new.work