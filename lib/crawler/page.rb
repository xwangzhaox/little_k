# page.rb

require 'nokogiri'
require 'open-uri'
require 'crawler/page/simple_code'
# require 'crawler/report'
# require 'crawler/page/modularization'
require 'crawler/page/to_object'

module Crawler
	module Page

		class << self

			def SimpleCode(url)
				SimpleCode.new url
			end

			def ToObject(hash)
				ToObject.new hash
			end

			def update_page_data_by_day
				# if # 抓取信息点有存储
				# 	# 按照信息点位置，再抓一遍
				# else
				# 	# 对比两张网页，获取不同点
					
				# end
			end
		end
	end
end