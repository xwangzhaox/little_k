$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'nokogiri'
require 'open-uri'
require 'pry'
require 'crawler/simple_code'
require 'crawler/modularization'
require 'crawler/to_object'

module Crawler
	class Crawler

		include SimpleCode

		def work
			@ttd = %w(https://xueqiu.com/S/SZ000736 https://xueqiu.com/S/SH601595/GSJJ https://xueqiu.com/S/SH600977 https://xueqiu.com/S/SH601595 https://xueqiu.com/S/SH601595)
			@doc1 = Nokogiri::HTML(open(@ttd.first)).css('body')
			@doc2 = Nokogiri::HTML(open(@ttd[1])).css('body')
			# f1 = File.open("crawler/testing_data/testing_1.html")
			# @doc1 = Nokogiri::HTML(f1).css('body')
			# f2 = File.open("crawler/testing_data/testing_2.html")
			# @doc2 = Nokogiri::HTML(f2).css('body')
			# f3 = File.open("testing_data/testing_3.html")
			# @doc3 = Nokogiri::HTML(f3).css('body')

			commen_stru, diff_stru = comparsion_page @doc1, @doc2
			print_diff_to_page diff_stru
		end

		def testing
			
		end
	end
end
Crawler::Crawler.new.work