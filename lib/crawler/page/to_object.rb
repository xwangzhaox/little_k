# to_object.rb

module Crawler
	module Page
		class ToObject
			attr_accessor :diff_hash, :page

			def initialize(options)
				@diff_hash = options[:diff]
				@page = Nokogiri::HTML(open(options[:url]))
			end

			def first_child
				# @diff_hash.first[0].values[0][:xpath] 示例数据如下：
				# [{"3-2-2-7-1-1"=>{:name=>"span", :id=>nil, :class=>"stockName", :content=>"中房地产(SZ:000736)", :xpath=>"/html/body/div[3]/div[2]/div[2]/div[1]/div[1]/span[1]"}}, {"3-2-2-7-1-1"=>{:name=>"span", :id=>nil, :class=>"stockName", :content=>"中国电影(SH:600977)", :xpath=>"/html/body/div[3]/div[2]/div[2]/div[1]/div[1]/span[1]"}}]
				puts @page.at_xpath(@diff_hash.first[0].values[0][:xpath]).to_html
			end
		end
	end
end