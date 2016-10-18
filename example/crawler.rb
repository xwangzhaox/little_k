#encoding=UTF-8
ASSETS_DIR = File.expand_path File.join(File.dirname(__FILE__), '../lib')
$LOAD_PATH.unshift(ASSETS_DIR)

require 'pry'
require 'crawler/page'
# require 'crawler/report'

module Crawler
	class Crawler

		def work
			@ttd = %w(https://xueqiu.com/S/SZ000736 https://xueqiu.com/S/SH601595/GSJJ https://xueqiu.com/S/SH600977 https://xueqiu.com/S/SH601595 https://xueqiu.com/S/SH601595)
			@page1 = Page.SimpleCode @ttd.first
			# puts @page1.scan_html_structrue
			a, b = @page1.comparsion_page @ttd[2]
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