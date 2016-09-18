$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'pry'
require 'crawler/page'

module Crawler
	class Crawler

		def work
			@ttd = %w(https://xueqiu.com/S/SZ000736 https://xueqiu.com/S/SH601595/GSJJ https://xueqiu.com/S/SH600977 https://xueqiu.com/S/SH601595 https://xueqiu.com/S/SH601595)
			@page1 = Page.SimpleCode @ttd.first
			@page1.scan_html_strctrue
			@page1.comparsion_page Nokogiri::HTML(open("https://xueqiu.com/S/SH601595/GSJJ")).css('body')
		end

		def testing
		end
	end
end
Crawler::Crawler.new.work